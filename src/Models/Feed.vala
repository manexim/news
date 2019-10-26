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

public class Models.Feed {
    private string _url;
    public string url { get { return _url; }}
    private string _title;
    public string title { get { return _title; }}
    private string _description;
    public string description { get { return _description; }}
    private string _link;
    public string link { get { return _link; }}
    private string _copyright;
    public string copyright { get { return _copyright; }}

    public Feed (string url) {
        _url = url;
    }

    public Article[] articles {
        owned get {
            var _articles = new Array<Article> ();

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", _url);

            session.send_message (message);

            string response = (string) message.response_body.data;

            var doc = Xml.Parser.parse_doc (response);
            if (doc == null) {
                stderr.printf ("failed to read the .xml file\n");
                return _articles.data;
            }

            Xml.Node* root = doc->get_root_element ();
            if (root == null) {
                stderr.printf ("failed to read the root\n");
                return _articles.data;
            }

            switch (root->name) {
                case "rss":
                    return this.parse_rss (root);
                case "feed":
                default:
                    stderr.printf ("not implemented\n");
                    return _articles.data;
            }
        }
    }

    private Article[] parse_rss (Xml.Node* root) {
        // find channel element
	    var channel = root->children;
	    for (;channel->name != "channel"; channel = channel->next);

	    var _articles = new Array<Article> ();

	    // loop through elements
	    for (var child = channel->children; child != null; child = child->next) {
	        switch (child->name) {
                case "title":
                    _title = child->get_content ().strip ();
                    break;
                case "description":
                    _description = child->get_content ().strip ();
                    break;
                case "link":
                    _link = child->get_content ().strip ();
                    break;
                case "copyright":
                    _copyright = child->get_content ().strip ();
                    break;
                case "item":
                var article = new Article ();
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
                                article.published = Utilities.DateTime.parse_rfc822 (childitem->get_content ().strip ());
                                break;
                        }
                    }

                    _articles.append_val (article);
                    break;
	        }
	    }
        
        return _articles.data;
    }
}
