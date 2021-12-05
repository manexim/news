/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Views.FeedView : Gtk.ScrolledWindow {
    private Gtk.Stack stack;
    private Views.LoadingView loading_view;
    private Gtk.Grid grid;
    private Widgets.ArticleCarousel articles_carousel;

    public FeedView () {
        stack = new Gtk.Stack ();
        add (stack);

        loading_view = new Views.LoadingView (
            _("Loading articles")
        );

        stack.add (loading_view);

        grid = new Gtk.Grid ();
        grid.margin = 12;
        stack.add (grid);

        articles_carousel = new Widgets.ArticleCarousel ();

        var articles_grid = new Gtk.Grid ();
        articles_grid.margin = 2;
        articles_grid.margin_top = 12;
        articles_grid.attach (articles_carousel, 0, 0, 1, 1);

        grid.attach (articles_grid, 0, 0, 1, 1);

        articles_carousel.on_article_activated.connect ((article) => {
            var article_view = new Views.ArticleView (article);

            MainWindow.get_default ().go_to_page (
                article_view,
                article.title
            );
        });

        foreach (var article in Store.get_default ().articles) {
            add_article (article);
        }

        Store.get_default ().on_add_article.connect ((article) => {
            add_article (article);
        });
    }

    private void add_article (Models.Article article) {
        if (stack.visible_child == loading_view) {
            stack.set_visible_child (grid);
            stack.remove (loading_view);
        }

        articles_carousel.add_article (article);
    }
}
