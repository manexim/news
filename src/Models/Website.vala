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
                stderr.printf ("failed to read the .xml file\n");

                return "";
            }

            Xml.XPath.Context context = new Xml.XPath.Context (doc);
            if (context == null) {
                stderr.printf ("failed to create the xpath context\n");
            }

            Xml.XPath.Object* obj = context.eval_expression ("/html");
            if (obj == null) {
                stderr.printf ("failed to evaluate xpath\n");
            }

            Xml.Node* node = null;
            if (obj->nodesetval != null && obj->nodesetval->item (0) != null) {
                node = obj->nodesetval->item (0);
            } else {
                stderr.printf ("failed to find the expected node\n");
            }

            result = node->get_content ();

            delete obj;
            delete doc;
            Xml.Parser.cleanup ();

            return result;
        }
    }
}
