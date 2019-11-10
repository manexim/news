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

public class MainWindow : Gtk.ApplicationWindow {
    private static MainWindow? instance;
    private Services.Settings settings;
    private Gtk.Stack stack;
    private Gtk.Button return_button;
    private Utilities.History history;

    public MainWindow (Gtk.Application application) {
        instance = this;
        this.application = application;

        history = new Utilities.History ();

        settings = Services.Settings.get_default ();
        load_settings ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;

        return_button = new Gtk.Button ();
        return_button.no_show_all = true;
        return_button.valign = Gtk.Align.CENTER;
        return_button.get_style_context ().add_class ("back-button");
        return_button.clicked.connect (go_back);
        headerbar.pack_start (return_button);

        set_titlebar (headerbar);
        title = Config.APP_NAME;

        stack = new Gtk.Stack ();
        add (stack);

        var feed = new Controllers.FeedController (
            new Models.Feed ("https://blog.elementary.io/feed.xml")
        );
        stack.add_named (feed.view, Config.APP_NAME);
        history.add (Config.APP_NAME);

        delete_event.connect (() => {
            save_settings ();

            return false;
        });
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

            title = Config.APP_ID;
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
