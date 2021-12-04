/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Views.ArticlePreview : WebKit.WebView {
    public ArticlePreview (Models.Article article) {
        var settings = get_settings ();
        settings.enable_plugins = false;
        settings.enable_javascript = false;

        load_html (article.about, Utilities.URL.base (article.url));
    }
}
