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

public class Models.Feed : Object {
    public string url { get; construct set; }
    public Array<Article> articles { get; construct set; }
    public string title { get; set; }
    public string description { get; set; }
    public string link { get; set; }
    public string source { get; set; }
    public string copyright { get; set; }
    public string favicon { get; set; }

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
