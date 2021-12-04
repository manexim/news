/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Widgets.ArticleCarousel : Gtk.FlowBox {
    public signal void on_article_activated (Models.Article article);

    public ArticleCarousel () {
        Object (
            activate_on_single_click: true,
            homogeneous: true
        );
    }

    construct {
        column_spacing = 12;
        row_spacing = 12;
        hexpand = true;
        max_children_per_line = 5;
        min_children_per_line = 2;
        selection_mode = Gtk.SelectionMode.NONE;
        child_activated.connect (on_child_activated);
    }

    public void add_article (Models.Article? article) {
        var carousel_item = new ArticleCarouselItem (article);
        add (carousel_item);
        unselect_child (carousel_item);
        show_all ();
    }

    private void on_child_activated (Gtk.FlowBoxChild child) {
        if (child is ArticleCarouselItem) {
            var article = ((ArticleCarouselItem)child).article;
            on_article_activated (article);
        }
    }
}
