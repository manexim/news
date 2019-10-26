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

public class Widgets.Image : Granite.AsyncImage {
    public Image.from_url (string url) {
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);

        session.send_message (message);

        var stream = new MemoryInputStream.from_data (message.response_body.data);

        try {
            pixbuf = new Gdk.Pixbuf.from_stream (stream);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    public void scale (int width, int height, bool keep_ratio = true) {
        if ((pixbuf.get_width () * pixbuf.get_height ()) > (width * height)) {
            if (!keep_ratio) {
                pixbuf = pixbuf.scale_simple (width, height, Gdk.InterpType.BILINEAR);
                return;
            }

            if (pixbuf.get_width () > pixbuf.get_height ()) {
                int w = width;
                int h = (int) ((1.0 * pixbuf.get_height () / pixbuf.get_width ()) * w + 0.5);

                pixbuf = pixbuf.scale_simple (w, h, Gdk.InterpType.BILINEAR);
            } else {
                int h = height;
                int w = (int) ((1.0 * pixbuf.get_width () / pixbuf.get_height ()) * h + 0.5);

                pixbuf = pixbuf.scale_simple (w, h, Gdk.InterpType.BILINEAR);
            }
        }
    }

    public void scale_height (int height) {
        int h = height;
        int w = (int) ((1.0 * pixbuf.get_width () / pixbuf.get_height ()) * h + 0.5);

        pixbuf = pixbuf.scale_simple (w, h, Gdk.InterpType.BILINEAR);
    }
}
