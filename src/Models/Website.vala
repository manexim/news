/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Models.Website : Object {
    public string url { get; construct set; }

    public Website (string url) {
        Object (
            url: url
        );
    }

    public string feed_url {
        owned get {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            session.send_message (message);

            string response = (string) message.response_body.data;

            string result = "";

            Xml.Doc* doc;
            var patched = response.replace ("&", "&amp;");

            Xml.Parser.init ();

            doc = Xml.Parser.read_memory (patched, patched.length, null, null, 1);
            if (doc == null) {
                warning ("failed to read the .xml file\n");

                return "";
            }

            Xml.XPath.Context context = new Xml.XPath.Context (doc);
            if (context == null) {
                warning ("failed to create the xpath context\n");
            }

            Xml.XPath.Object* obj = context.eval_expression ("/html");
            if (obj == null) {
                warning ("failed to evaluate xpath\n");
            }

            Xml.Node* node = null;
            if (obj->nodesetval != null && obj->nodesetval->item (0) != null) {
                node = obj->nodesetval->item (0);
            } else {
                warning ("failed to find the expected node\n");
            }

            result = node->get_content ();

            delete obj;
            delete doc;
            Xml.Parser.cleanup ();

            return result;
        }
    }
}
