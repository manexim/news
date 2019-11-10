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

public class Controllers.FeedController : Object {
    public Models.Feed model { get; construct set; }
    public Views.FeedView view { get; set; }

    public signal void updated ();

    public FeedController (
        Models.Feed model,
        Views.FeedView? view = null,
        bool parse_articles = false
    ) {
        Object (
            model: model,
            view: view
        );

        update (parse_articles);
    }

    public void update (bool parse_articles = false) {
        new Thread<void*> (null, () => {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", model.url);

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
                    parse_rss (root, parse_articles);
                    break;
                case "feed":
                    parse_atom (root, parse_articles);
                    break;
                default:
                    warning ("not implemented\n");
                    break;
            }

            updated ();

            return null;
        });
    }

    private void parse_rss (Xml.Node* root, bool parse_articles = false) {
        // find channel element
        var channel = root->children;
        for (;channel->name != "channel"; channel = channel->next);

        // loop through elements
        for (var child = channel->children; child != null; child = child->next) {
            switch (child->name) {
                case "title":
                    model.title = child->get_content ().strip ();
                    break;
                case "description":
                    model.description = child->get_content ().strip ();
                    break;
                case "link":
                    model.link = child->get_content ().strip ();
                    break;
                case "copyright":
                    model.copyright = child->get_content ().strip ();
                    break;
                case "item":
                    if (parse_articles) {
                        var article = new Models.Article ();
                        for (var childitem = child->children; childitem != null; childitem = childitem->next) {
                            switch (childitem->name) {
                                case "title":
                                    article.title = childitem->get_content ().replace ("&", "&amp;").strip ();
                                    break;
                                case "link":
                                    article.url = childitem->get_content ().strip ();
                                    break;
                                case "description":
                                    article.about = childitem->get_content ().strip ();
                                    if (article.about.length == 0) {
                                        article.about = null;
                                    }

                                    break;
                                case "encoded":
                                    article.content = childitem->get_content ().strip ();
                                    break;
                                case "pubDate":
                                    article.published = Utilities.DateTime.parse_rfc822 (
                                        childitem->get_content ().strip ()
                                    );
                                    break;
                            }
                        }

                        var article_controller = new Controllers.ArticleController (article);
                        article_controller.update ();

                        model.add_article (article_controller.model);
                    }

                    break;
            }
        }
    }

    private void parse_atom (Xml.Node* root, bool parse_articles = false) {
        for (var child = root->children; child != null; child = child->next) {
            switch (child->name) {
                case "title":
                    model.title = child->get_content ();
                    break;
                case "subtitle":
                    model.description = child->get_content ();
                    break;
                case "link":
                    if (child->get_prop ("rel") == "self") {
                        model.source = child->get_prop ("href");
                    } else {
                        model.url = child->get_prop ("href");
                    }
                    break;
                case "entry":
                    if (parse_articles) {
                        var article = new Models.Article ();
                        for (var childitem = child->children; childitem != null; childitem = childitem->next) {
                            switch (childitem->name) {
                                case "title":
                                    article.title = childitem->get_content ();
                                    break;
                                case "summary":
                                    article.about = childitem->get_content ();
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
                                    article.updated = new DateTime.from_iso8601 (
                                        childitem->get_content (), new TimeZone.utc ()
                                    );

                                    if (article.published == null) {
                                        article.published = new DateTime.from_iso8601 (
                                            childitem->get_content (), new TimeZone.utc ()
                                        );
                                    }

                                    break;
                            }
                        }

                        var article_controller = new Controllers.ArticleController (article);
                        article_controller.update ();

                        model.add_article (article_controller.model);
                    }

                    break;
            }
        }
    }
}
