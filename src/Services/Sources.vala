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

public class Services.Sources : Object {
    private static Sources instance;

    public Array<Models.Feed> sources { get; construct set; }

    public signal void added_source (Models.Feed feed);

    public static Sources get_default () {
        if (instance == null) {
            instance = new Sources ();
        }

        return instance;
    }

    public void add_source (Models.Feed source) {
        sources.append_val (source);

        added_source (source);
    }

    private Sources () {
        Object (
            sources: new Array<Models.Feed> ()
        );
    }

    public void update () {
        new Thread<void*> (null, () => {
            {
                var model = new Models.Feed ("https://blog.elementary.io/feed.xml");
                model.favicon = "https://elementary.io/favicon.ico";
                model.subscribed = true;

                var controller = new Controllers.FeedController (model);
                controller.updated.connect (() => {
                    add_source (model);
                });
            }

            {
                var model = new Models.Feed ("https://www.omgubuntu.co.uk/feed");
                model.favicon = "https://149366088.v2.pressablecdn.com/wp-content/themes/omgubuntu-theme-19_10_1/images/favicons/apple-icon-57x57.png";

                var controller = new Controllers.FeedController (model);
                controller.updated.connect (() => {
                    add_source (model);
                });
            }

            {
                var model = new Models.Feed ("https://www.theverge.com/rss/index.xml");
                model.favicon = "https://cdn.vox-cdn.com/community_logos/52801/VER_Logomark_32x32..png";

                var controller = new Controllers.FeedController (model);
                controller.updated.connect (() => {
                    add_source (model);
                });
            }

            return null;
        });
    }
}
