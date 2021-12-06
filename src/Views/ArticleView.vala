/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Views.ArticleView : WebKit.WebView {
    public void load (Models.Article article) {
        load_uri (article.url);
    }

    public ArticleView () {
        var settings = get_settings ();
        settings.enable_javascript = true;

        load_uri ("");
    }
}
