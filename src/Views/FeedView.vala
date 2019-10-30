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

public class Views.FeedView : Gtk.ScrolledWindow {
    public Models.Feed model { get; construct set; }

    public FeedView (Models.Feed model) {
        Object (
            model: model
        );

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        add (grid);

        var articles_carousel = new Widgets.ArticleCarousel ();

        var articles_grid = new Gtk.Grid ();
        articles_grid.margin = 2;
        articles_grid.margin_top = 12;
        articles_grid.attach (articles_carousel, 0, 0, 1, 1);

        grid.attach (articles_grid, 0, 0, 1, 1);

        for (uint i = 0; i < model.articles.length; i++) {
            var article = model.articles.index (i);

            articles_carousel.add_article (article);
        }

        articles_carousel.on_article_activated.connect ((article) => {
            var article_view = new Views.ArticleView (article);

            MainWindow.get_default ().go_to_page (
                article_view,
                article.title
            );
        });

        model.added_article.connect ((article) => {
            articles_carousel.add_article (article);
        });
    }
}
