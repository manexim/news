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

public class MainWindow : Hdy.Window {
    private static MainWindow? instance;
    private Services.Settings settings;
    private Gtk.Label news_header;
    private Gtk.Stack custom_title_stack;
    private Granite.Widgets.ModeButton view_mode;
    private Gtk.Revealer view_mode_revealer;
    private Gtk.Stack stack;
    private Gtk.Button return_button;
    private Utilities.History history;

    private Controllers.FeedController feed;
    private Views.SourcesView sources_view;

    private int news_view_id;
    private int sources_view_id;

    public MainWindow (Gtk.Application application) {
        instance = this;
        this.application = application;

        history = new Utilities.History ();

        settings = Services.Settings.get_default ();
        load_settings ();

        view_mode = new Granite.Widgets.ModeButton ();
        view_mode.margin_end = view_mode.margin_start = 12;
        view_mode.margin_bottom = view_mode.margin_top = 7;
        news_view_id = view_mode.append_text (Config.APP_NAME);
        sources_view_id = view_mode.append_text (_("Sources"));

        view_mode.selected = news_view_id;

        var view_mode_overlay = new Gtk.Overlay ();
        view_mode_overlay.add (view_mode);

        view_mode_revealer = new Gtk.Revealer ();
        view_mode_revealer.reveal_child = true;
        view_mode_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        view_mode_revealer.add (view_mode_overlay);

        news_header = new Gtk.Label (null);
        news_header.get_style_context ().add_class (Gtk.STYLE_CLASS_TITLE);

        custom_title_stack = new Gtk.Stack ();
        custom_title_stack.add (view_mode_revealer);
        custom_title_stack.add (news_header);
        custom_title_stack.set_visible_child (view_mode_revealer);

        var headerbar = new Hdy.HeaderBar () {
            decoration_layout = "close:",
            show_close_button = true
        };
        headerbar.set_custom_title (custom_title_stack);

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
            feed = new Controllers.FeedController (
                model,
                new Views.FeedView (model),
                true
            );
        }
        stack.add_named (feed.view, Config.APP_NAME);
        history.add (Config.APP_NAME);

        sources_view = new Views.SourcesView ();
        stack.add_named (sources_view, _("Sources"));

        delete_event.connect (() => {
            save_settings ();

            return false;
        });

        view_mode.notify["selected"].connect (on_view_mode_changed);
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

    private void on_view_mode_changed () {
        if (view_mode.selected == news_view_id) {
            if (!history.is_homepage) {
                return_button.visible = true;
            }

            stack.visible_child_name = history.current;
        } else if (view_mode.selected == sources_view_id) {
            return_button.visible = false;
            stack.visible_child = sources_view;
        }
    }
}
