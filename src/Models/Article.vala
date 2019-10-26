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

public class Models.Article {
    public string? title;
    public string? about;
    public string? content;
    public string? url;
    public string? favicon;
    public DateTime? published;
    public DateTime? updated;

    public string? image {
        owned get {
            if (about != null) {
                try {
                    Regex regex = new Regex (".*<img.*src=\"([^\"]*)\"");
                    MatchInfo mi;
                    var match = regex.match (about, 0, out mi);
                    if (match) {
                        var _image = mi.fetch (1);

                        if (Utilities.URL.is_absolute (_image)) {
                            return _image;
                        } else {
                            return Utilities.URL.join (Utilities.URL.base (url), _image);
                        }
                    }
                } catch (RegexError e) {
                    stderr.printf ("RegexError %s\n", e.message);
                }
            }

            return null;
        }
    }
}
