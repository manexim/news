/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class MainWindow : Hdy.Window {
    private static MainWindow? instance;
    private Services.Settings settings;

    private Gtk.ListBox article_list_box;
    private Views.ArticleView article_view;

    public MainWindow (Gtk.Application application) {
        instance = this;
        this.application = application;

        settings = Services.Settings.get_default ();
        load_settings ();

        var headerbar = new Hdy.HeaderBar () {
            decoration_layout = "close:",
            show_close_button = true,
            title = Constants.APP_NAME
        };

        article_list_box = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.SINGLE
        };

        var article_list_scrolled = new Gtk.ScrolledWindow (null, null);
        article_list_scrolled.add (article_list_box);

        article_view = new Views.ArticleView ();

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            vexpand = true,
            position = 400
        };
        paned.pack1 (article_list_scrolled, false, false);
        paned.pack2 (article_view, true, true);

        var main_layout = new Gtk.Grid ();
        main_layout.attach (headerbar, 0, 0);
        main_layout.attach (paned, 0, 1);

        add (main_layout);

        delete_event.connect (() => {
            save_settings ();

            return false;
        });

        foreach (var article in Store.get_default ().articles) {
            add_article (article);
        }

        Store.get_default ().on_add_article.connect ((article) => {
            add_article (article);
        });

        article_list_box.row_selected.connect ((row) => {
            var article = ((Widgets.ArticleRow) row).article;
            article_view.load (article);
            headerbar.title = article.title;
        });
    }

    private void add_article (Models.Article article) {
        var row = new Widgets.ArticleRow (article);
        article_list_box.insert (row, -1);
        article_list_box.show_all ();
    }

    construct {
        Hdy.init ();
    }

    public static MainWindow get_default () {
        return instance;
    }

    private void load_settings () {
        if (settings.window_maximized) {
            maximize ();
            set_default_size (settings.window_width, settings.window_height);
        } else {
            set_default_size (settings.window_width, settings.window_height);
        }

        if (settings.window_x < 0 || settings.window_y < 0 ) {
            window_position = Gtk.WindowPosition.CENTER;
        } else {
            move (settings.window_x, settings.window_y);
        }
    }

    private void save_settings () {
        settings.window_maximized = is_maximized;

        if (!settings.window_maximized) {
            int x, y;
            get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;

            int width, height;
            get_size (out width, out height);
            settings.window_width = width;
            settings.window_height = height;
        }
    }
}
