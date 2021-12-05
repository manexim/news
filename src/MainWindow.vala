/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

 public class MainWindow : Hdy.Window {
    private static MainWindow? instance;
    private Services.Settings settings;

    private Gtk.ListBox listbox;
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

        listbox = new Gtk.ListBox ();

        var list_scrolled = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            width_request = 158,
            expand = true
        };
        list_scrolled.add (listbox);

        article_view = new Views.ArticleView ();

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            vexpand = true
        };
        paned.pack1 (list_scrolled, false, false);
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

        listbox.row_selected.connect ((row) => {
            print ("select: row == null: %s\n", row == null ? "true" : "false");
            if (row != null && row is Widgets.ArticleCarouselItem) {
                var item = (Widgets.ArticleCarouselItem) row;
                print ("item: %s\n", item.article.url);
                article_view.load (item.article);
            } else {
                article_view.load_uri ("");
            }
        });
    }

    private void add_article (Models.Article article) {
        var item = new Widgets.ArticleCarouselItem (article);
        listbox.insert (item, -1);
        listbox.show_all ();

        article_view.load (article);
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
