/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class MainWindow : Hdy.Window {
    private static MainWindow? instance;
    private Services.Settings settings;
    private Gtk.Stack stack;
    private Gtk.Button return_button;
    private Utilities.History history;

    private Controllers.FeedController feed;

    public MainWindow (Gtk.Application application) {
        instance = this;
        this.application = application;

        history = new Utilities.History ();

        settings = Services.Settings.get_default ();
        load_settings ();

        var headerbar = new Hdy.HeaderBar () {
            decoration_layout = "close:",
            show_close_button = true,
            title = Config.APP_NAME
        };

        return_button = new Gtk.Button ();
        return_button.no_show_all = true;
        return_button.valign = Gtk.Align.CENTER;
        return_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        return_button.clicked.connect (go_back);
        headerbar.pack_start (return_button);

        stack = new Gtk.Stack () {
            hexpand = true,
            vexpand = true
        };

        var main_layout = new Gtk.Grid ();
        main_layout.attach (headerbar, 0, 0);
        main_layout.attach (stack, 0, 1);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (main_layout);

        add (window_handle);

        {
            var model = new Models.Feed ("https://blog.elementary.io/feed.xml");
            //  var model = new Models.Feed ("https://www.theverge.com/rss/index.xml");
            feed = new Controllers.FeedController (
                model,
                new Views.FeedView (model),
                true
            );
        }
        stack.add_named (feed.view, Config.APP_NAME);
        history.add (Config.APP_NAME);

        delete_event.connect (() => {
            save_settings ();

            return false;
        });
    }

    construct {
        Hdy.init ();
    }

    public static MainWindow get_default () {
        return instance;
    }

    public void go_to_page (Gtk.Widget page, string name) {
        page.show_all ();
        stack.add_named (page, name);

        return_button.label = history.current;
        return_button.no_show_all = false;
        return_button.visible = true;
        history.add (name);
        title = name;
        stack.set_visible_child_full (name, Gtk.StackTransitionType.SLIDE_LEFT);
    }

    public void go_back () {
        if (!history.is_homepage) {
            var widget = stack.get_visible_child ();

            stack.set_visible_child_full (history.previous, Gtk.StackTransitionType.SLIDE_RIGHT);
            stack.remove (widget);

            history.pop ();
        }

        if (!history.is_homepage) {
            return_button.label = history.previous;
            title = history.current;
        } else {
            return_button.no_show_all = true;
            return_button.visible = false;

            title = Config.APP_NAME;
        }
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
