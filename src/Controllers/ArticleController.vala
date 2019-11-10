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

public class Controllers.ArticleController : Object {
    public Models.Article model { get; construct set; }

    public ArticleController (Models.Article model) {
        Object (
            model: model
        );
    }

    public void update () {
        get_image_url ();
        get_favicon_url ();
    }

    private void get_image_url () {
        if (model.about != null) {
            try {
                Regex regex = new Regex (".*<img.*src=\"([^\"]*)\"");
                MatchInfo mi;
                var match = regex.match (model.about, 0, out mi);
                if (match) {
                    var image = mi.fetch (1);

                    if (Utilities.URL.is_absolute (image)) {
                        model.image = image;
                    } else {
                        model.image = Utilities.URL.join (Utilities.URL.base (model.url), image);
                    }
                }
            } catch (RegexError e) {
                error ("RegexError %s\n", e.message);
            }
        }
    }

    private void get_favicon_url () {
        model.favicon = "https://elementary.io/favicon.ico";
    }
}
