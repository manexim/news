/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Store : Flux.Store {
    private static Store instance;

    public static Store get_default () {
        if (instance == null) {
            instance = new Store ();
        }

        return instance;
    }

    private Store () {}

    public Gee.List<Models.Feed> feeds;
    public Gee.List<Models.Article> articles;

    public signal void on_add_feed (Models.Feed feed);
    public signal void on_add_article (Models.Article article);

    public override void process (Flux.Action action) {
        switch (action.action_type) {
            case ActionType.ADD_FEED:
                process_add_feed (action);
                break;
            case ActionType.ADD_ARTICLE:
                process_add_article (action);
                break;
        }
    }

    private void process_add_feed (Flux.Action action) {
        var payload = (Payload.AddFeed) action.payload;

        foreach (var feed in feeds) {
            if (feed.url == payload.url) {
                return;
            }
        }

        var feed = new Models.Feed (payload.url) {
            title = payload.title,
            description = payload.description,
            website = payload.website,
            icon = payload.icon
        };

        feeds.add (feed);
        on_add_feed (feed);
    }

    private void process_add_article (Flux.Action action) {
        var payload = (Payload.AddArticle) action.payload;

        foreach (var article in articles) {
            if (article.url == payload.url) {
                return;
            }
        }

        var article = new Models.Article () {
            feed_title = payload.feed_title,
            title = payload.title,
            summary = payload.summary,
            header_image = payload.header_image,
            published = payload.published
        };

        articles.add (article);
        on_add_article (article);
    }

    construct {
        feeds = new Gee.ArrayList<Models.Feed> ();
        articles = new Gee.ArrayList<Models.Article> ();
    }
}
