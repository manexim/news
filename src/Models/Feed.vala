/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Models.Feed : Object {
    public string url { get; construct set; }
    public Array<Article> articles { get; construct set; }
    public string title { get; set; }
    public string description { get; set; }
    public string link { get; set; }
    public string source { get; set; }
    public string copyright { get; set; }
    public string favicon { get; set; }
    public bool subscribed { get; set; }

    public signal void added_article (Models.Article article);

    public Feed (string url) {
        Object (
            url: url,
            articles: new Array<Article> ()
        );
    }

    public void add_article (Models.Article article) {
        articles.append_val (article);

        added_article (article);
    }
}
