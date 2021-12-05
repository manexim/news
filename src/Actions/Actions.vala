/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Actions {
    void add_feed (string url, string title, string description, string website, string icon) {
        var type = ActionType.ADD_FEED;
        var payload = new Payload.AddFeed () {
            url = url,
            title = title,
            description = description,
            website = website,
            icon = icon
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    void add_feed_request (string url) {
        var type = ActionType.ADD_FEED_REQUEST;
        var payload = new Payload.AddFeedRequest () {
            url = url
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    void add_article (string feed_title, string url, string header_image, string title, string summary, DateTime published) {
        var type = ActionType.ADD_ARTICLE;
        var payload = new Payload.AddArticle () {
            feed_title = feed_title,
            url = url,
            header_image = header_image,
            title = title,
            summary = summary,
            published = published
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }
}
