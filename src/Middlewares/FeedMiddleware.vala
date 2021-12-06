/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class FeedMiddleware : Flux.Middleware {
    private signal void on_add_feed_response (Payload.AddFeed feed);
    private signal void on_add_article_response (Payload.AddArticle article);

    construct {
        on_add_feed_response.connect (process_add_feed_response);
        on_add_article_response.connect (process_add_article_response);
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
                    parse_rss (root, payload.url, parse_articles);
                    break;
                case "feed":
                    parse_atom (root, payload.url, parse_articles);
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

    private void process_add_article_response (Payload.AddArticle article) {
        Actions.add_article (
            article.feed_title,
            article.url,
            article.header_image,
            article.title,
            article.summary,
            article.published
        );
    }

    private void parse_rss (Xml.Node* root, string url, bool parse_articles = false) {
        Payload.AddFeed feed = new Payload.AddFeed () {
            url = url
        };
        var articles = new Gee.ArrayList<Payload.AddArticle> ();

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
                case "item":
                    var article = new Payload.AddArticle () {
                        feed_title = feed.title
                    };

                    for (var childitem = child->children; childitem != null; childitem = childitem->next) {
                        switch (childitem->name) {
                            case "title":
                                article.title = childitem->get_content ().replace ("&", "&amp;").strip ();
                                break;
                            case "link":
                                article.url = childitem->get_content ().strip ();
                                break;
                            case "description":
                                content = childitem->get_content ().strip ();
                                if (content.length > 0) {
                                    article.summary = get_content_text (content).substring (0, 200);
                                    article.header_image = get_header_image_url (url, content);
                                }

                                break;
                            case "pubDate":
                                article.published = Utilities.DateTime.parse_rfc822 (
                                    childitem->get_content ().strip ()
                                );
                                break;
                        }
                    }

                    articles.add (article);

                    break;
            }
        }

        Idle.add (() => {
            on_add_feed_response (feed);
            foreach (var article in articles) {
                on_add_article_response (article);
            }

            return false;
        });
    }

    private void parse_atom (Xml.Node* root, string url, bool parse_articles = false) {
        Payload.AddFeed feed = new Payload.AddFeed () {
            url = url
        };
        var articles = new Gee.ArrayList<Payload.AddArticle> ();

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
                case "entry":
                    var article = new Payload.AddArticle () {
                        feed_title = feed.title
                    };

                    for (var childitem = child->children; childitem != null; childitem = childitem->next) {
                        switch (childitem->name) {
                            case "title":
                                article.title = childitem->get_content ().replace ("&", "&amp;").strip ();
                                break;
                            case "content":
                                content = childitem->get_content ().strip ();
                                if (content.length > 0) {
                                    article.summary = get_content_text (content).substring (0, 200);
                                    article.header_image = get_header_image_url (url, content);
                                }
                                break;
                            case "link":
                                if (article.url == null) {
                                    article.url = childitem->get_prop ("href");
                                }
                                break;
                            case "published":
                                article.published = new DateTime.from_iso8601 (
                                    childitem->get_content (), new TimeZone.utc ()
                                );
                                break;
                            case "updated":
                                if (article.published == null) {
                                    article.published = new DateTime.from_iso8601 (
                                        childitem->get_content (), new TimeZone.utc ()
                                    );
                                }

                                break;
                        }
                    }

                    articles.add (article);

                    break;
            }
        }

        Idle.add (() => {
            on_add_feed_response (feed);
            foreach (var article in articles) {
                on_add_article_response (article);
            }

            return false;
        });
    }

    private string get_icon (string url) {
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);

        session.send_message (message);

        string response = (string) message.response_body.data;

        try {
            var regex = new Regex (".*<link rel=\"shortcut icon\" href=\"(.*)\">.*");
            MatchInfo mi;
            if (regex.match (response, 0, out mi)) {
                var icon = mi.fetch (1);

                if (Utilities.URL.is_absolute (icon)) {
                    return icon;
                } else {
                    return Utilities.URL.join (Utilities.URL.base (url), icon);
                }
            }
        } catch (RegexError e) {
            warning ("RegexError %s\n", e.message);
            return "";
        }

        return "";
    }

    private string get_content_text (string content) {
        try {
            var regex = new Regex ("\\s\\s+");
            var s = regex.replace (content, content.length, 0, " ");

            regex = new Regex (".*(<figcaption>.*</figcaption>).*");
            s = regex.replace (s, s.length, 0, "");

            regex = new Regex ("<.*?>");
            s = regex.replace (s, s.length, 0, " ");

            regex = new Regex ("\\s\\s+");
            s = regex.replace (s, s.length, 0, " ");

            return s.strip ();
        } catch (RegexError e) {
            warning ("RegexError %s\n", e.message);
            return "";
        }
    }

    private string get_header_image_url (string url, string content) {
        try {
            var regex = new Regex (".*<img.*src=\"([^\"]*)\"");
            MatchInfo mi;
            var match = regex.match (content, 0, out mi);
            if (match) {
                var image = mi.fetch (1);

                if (Utilities.URL.is_absolute (image)) {
                    return image;
                } else {
                    return Utilities.URL.join (Utilities.URL.base (url), image);
                }
            }
        } catch (RegexError e) {
            warning ("RegexError %s\n", e.message);
            return "";
        }

        return "";
    }
}
