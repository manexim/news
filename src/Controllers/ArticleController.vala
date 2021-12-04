/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
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
                warning ("RegexError %s\n", e.message);
            }
        }
    }

    private void get_favicon_url () {
        model.favicon = "https://elementary.io/favicon.ico";
    }
}
