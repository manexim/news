/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class FeedMiddleware : Flux.Middleware {
    private signal void on_add_feed_response (Payload.AddFeed feed);

    construct {
        on_add_feed_response.connect (process_add_feed_response);
    }

    public override void process (Flux.Action action) {
        switch (action.action_type) {
            case ActionType.ADD_FEED_REQUEST:
                process_add_feed_request (action);
                break;
        }
    }

    private void process_add_feed_request (Flux.Action action) {
        var payload = (Payload.AddFeedRequest) action.payload;
        bool parse_articles = false;

        new Thread<void*> (null, () => {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", payload.url);

            session.send_message (message);

            string response = (string) message.response_body.data;

            var doc = Xml.Parser.parse_doc (response);
            if (doc == null) {
                warning ("failed to read the .xml file\n");
                return null;
            }

            Xml.Node* root = doc->get_root_element ();
            if (root == null) {
                warning ("failed to read the root\n");
                return null;
            }

            switch (root->name) {
                case "rss":
                    on_add_feed_response (parse_rss (root, payload.url, parse_articles));
                    break;
                case "feed":
                    on_add_feed_response (parse_atom (root, payload.url, parse_articles));
                    break;
                default:
                    warning ("not implemented\n");
                    break;
            }

            return null;
        });
    }

    private void process_add_feed_response (Payload.AddFeed feed) {
        Actions.add_feed (
            feed.url,
            feed.title,
            feed.description != null ? feed.description : "",
            feed.website != null ? feed.website : "",
            feed.icon != null ? feed.icon : ""
        );
    }

    private Payload.AddFeed parse_rss (Xml.Node* root, string url, bool parse_articles = false) {
        Payload.AddFeed feed = new Payload.AddFeed () {
            url = url
        };

        // find channel element
        var channel = root->children;
        for (;channel->name != "channel"; channel = channel->next);

        // loop through elements
        for (var child = channel->children; child != null; child = child->next) {
            var content = child->get_content ().strip ();
            if (content == null || content.length == 0) {
                continue;
            }

            switch (child->name) {
                case "title":
                    feed.title = content;
                    break;
                case "description":
                    feed.description = content;
                    break;
                case "link":
                    feed.website = content;
                    feed.icon = get_icon (feed.website);
                    break;
            }
        }

        return feed;
    }

    private Payload.AddFeed parse_atom (Xml.Node* root, string url, bool parse_articles = false) {
        Payload.AddFeed feed = new Payload.AddFeed () {
            url = url
        };

        for (var child = root->children; child != null; child = child->next) {
            var content = child->get_content ().strip ();

            switch (child->name) {
                case "title":
                    if (content != null && content.length > 0) {
                        feed.title = content;
                    }
                    break;
                case "subtitle":
                    if (content != null && content.length > 0) {
                        feed.description = content;
                    }
                    break;
                case "icon":
                    if (content != null && content.length > 0) {
                        feed.icon = content;
                    }
                    break;
                case "link":
                    if (child->get_prop ("rel") == "self") {
                        // ignore feed source
                    } else {
                        feed.website = child->get_prop ("href").strip ();
                    }
                    break;
            }
        }

        return feed;
    }

    private string get_icon (string url) {
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);

        session.send_message (message);

        string response = (string) message.response_body.data;

        try {
            var re = new Regex (".*<link rel=\"shortcut icon\" href=\"(.*)\">.*");

            MatchInfo mi;
            if (re.match (response, 0, out mi)) {
                return mi.fetch (1);
            }
        } catch (Error e) {
            return "";
        }

        return "";
    }
}
