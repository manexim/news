/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Services.ImageCache {
    private const int MAX_CACHE_SIZE = 100000000;

    public string image_path;
    private Soup.Session session;

    public static ImageCache? new_cache () {
        var image_path = Path.build_filename (
            GLib.Environment.get_user_cache_dir (),
            Path.DIR_SEPARATOR_S,
            Config.APP_ID,
            "images"
        );

        var session = new Soup.Session ();
        session.timeout = 5;

        debug ("image path is at %s\n", image_path);
        if (GLib.DirUtils.create_with_parents (image_path, 0755) == -1) {
            warning (
                "Error creating the temporary folder: GFileError #%d",
                GLib.FileUtils.error_from_errno (GLib.errno)
            );
            return null;
        } else {
            var cache = new ImageCache ();
            cache.image_path = image_path;
            cache.session = session;
            return cache;
        }
    }

    // Prune the cache directory if it exceeds the `MAX_CACHE_SIZE`.
    public void maintain () {
        var image_usage = summarize_image_usage ();
        if (image_usage == -1) {
            return;
        }

        if (image_usage > MAX_CACHE_SIZE) {
            delete_oldest_files (image_usage);
        }
    }

    // Attempt to open a directory for reading.
    private int read_dir (out Dir? dir, string path) {
        try {
            dir = Dir.open (path, 0);
            return 0;
        } catch (FileError e) {
            warning ("failed to read directory at %s: %s\n", path, e.message);
            dir = null;
            return -1;
        }
    }

    // Attempt to get the size of a given file.
    private int query_size (string path) {
        var file = File.new_for_path (path);
        try {
            FileInfo info = file.query_info ("standard::*", FileQueryInfoFlags.NONE);
            return (int) info.get_size ();
        } catch (Error e) {
            warning ("failed to get file metadata for %s: %s", path, e.message);
            return -1;
        }
    }

    // Attempt to delete the given file.
    private int delete_file (File file, string path) {
        try {
            file.delete ();
            return 0;
        } catch (Error e) {
            warning ("failed to delete %s: %s", path, e.message);
            return -1;
        }
    }

    // Delete the oldest files in the image cache until the cache is less than the max size.
    private void delete_oldest_files (int image_usage) {
        string? name = null;
        Dir dir;
        if (read_dir (out dir, image_path) == -1) {
            return;
        }

        while (image_usage > MAX_CACHE_SIZE) {
            string? oldest_path = null;
            time_t oldest_time = 0;
            while ((name = dir.read_name ()) != null) {
                string entry = Path.build_filename (image_path, name);
                Stat fstat = Stat (entry);
                if (oldest_time == 0 || fstat.st_mtime < oldest_time) {
                    oldest_time = fstat.st_mtime;
                    oldest_path = entry;
                }
            }

            if (null != oldest_path) {
                debug ("deleting image at %s to free cache\n", oldest_path);

                var file = File.new_for_path (oldest_path);
                int size = query_size (oldest_path);
                if (size == -1) {
                    return;
                }

                if (delete_file (file, oldest_path) == 0) {
                    image_usage -= size;
                } else {
                    return;
                }
            }
        }
    }

    // Get the combined size of the image cache.
    private int summarize_image_usage () {
        Dir dir;
        if (read_dir (out dir, image_path) == -1) {
            return -1;
        }

        string? name = null;
        int size = 0;

        while ((name = dir.read_name ()) != null) {
            string entry = Path.build_filename (image_path, name);
            int file_size = query_size (entry);
            if (file_size == -1) {
                return -1;
            }

            size += file_size;
        }

        return size;
    }

    // Generate a image path based on the URL to be fetched.
    private string generate_image_path (string url) {
        int ext_pos = url.last_index_of (".");
        string extension = url.slice ((long) ext_pos, (long) url.length);
        if (extension.contains ("/")) {
            extension = "";
        }

        return Path.build_filename (
            image_path,
            Path.DIR_SEPARATOR_S,
            "%02x".printf (url.hash ()) + extension
        );
    }

    /*
     * Fetches a image in a background thread.
     *
     * A result indicating the success (0) will be returned as the result upon completion.
     */
    public async int fetch (string url, out string out_file) {
        SourceFunc callback = fetch.callback;
        int result = 0;
        string path = generate_image_path (url);
        var file = File.new_for_path (path);

        new Thread<bool> ("fetching_image", () => {
            FileIOStream stream;
            bool download = true;
            time_t mtime = 0;

            try {
                if (file.query_exists ()) {
                    stream = file.open_readwrite ();
                    var msg = new Soup.Message ("HEAD", url);
                    session.send_message (msg);

                    if (msg.status_code != Soup.Status.OK) {
                        warning ("HEAD request of %s failed: %s\n", url, Soup.Status.get_phrase (msg.status_code));
                        result = 1;
                        Idle.add ((owned)callback);
                        return true;
                    }

                    // Compare the mtimes of the header and the existing file.
                    // If they're the same, we do not need to download it again.
                    var modified = msg.response_headers.get_one ("Last-Modified");
                    if (null != modified) {
                        var time = new Soup.Date.from_string (modified).to_time_t ();
                        if (Stat (path).st_mtime != time) {
                            mtime = time;
                        } else {
                            download = false;
                        }
                    }
                } else {
                    stream = file.create_readwrite (FileCreateFlags.NONE);
                }
            } catch (Error e) {
                warning ("failed to open image file for writing: %s\n", e.message);
                result = -1;
                Idle.add ((owned)callback);
                return true;
            }

            if (download) {
                debug ("downloading %s to %s\n", url, path);

                var msg = new Soup.Message ("GET", url);
                session.send_message (msg);

                if (msg.status_code != Soup.Status.OK) {
                    warning ("GET request of %s failed: %s\n", url, Soup.Status.get_phrase (msg.status_code));
                    result = 1;
                    Idle.add ((owned)callback);
                    return true;
                }

                var data = msg.response_body.data;

                // Ensure that what was downloaded is an image, before writing it.
                var content = msg.response_headers.get_one ("Content-Type");
                if (content == null || ! content.has_prefix ("image/")) {
                    warning ("fetched url is not of the image content type");
                    result = 1;
                    Idle.add ((owned)callback);
                    return true;
                }

                var output = stream.output_stream;
                try {
                    size_t written;
                    output.write_all (data, out written);
                    output.close ();
                } catch (IOError e) {
                    warning ("failed to write image to %s: %s\n", path, e.message);
                    delete_file (file, path);
                    result = -1;
                    Idle.add ((owned)callback);
                    return true;
                }

                var modified = msg.response_headers.get_one ("Last-Modified");
                if (null != modified) {
                    mtime = new Soup.Date.from_string (modified).to_time_t ();
                }
            }

            if (0 != mtime) {
                set_mtime (path, mtime);
            }

            Idle.add ((owned)callback);
            return true;
        });

        yield;
        out_file = path;
        return result;
    }

    // Used for setting the `Last-Modified` header's value to the image that was downloaded.
    private void set_mtime (string path, time_t mtime) {
        Stat fstat = Stat (path);

        var utimbuf = UTimBuf () {
            actime = fstat.st_atime,
            modtime = mtime
        };

        FileUtils.utime (path, utimbuf);
    }
}
