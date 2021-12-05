/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Application : Granite.Application {
    private MainWindow window;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });

        // Register Middlewares
        Flux.Dispatcher.get_instance ().register_middleware (new LoggingMiddleware ());

        Flux.Dispatcher.get_instance ().register_middleware (new FeedMiddleware ());

        // Register Stores
        Flux.Dispatcher.get_instance ().register_store (Store.get_default ());

        window = new MainWindow (this);

        window.show_all ();

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource (Constants.APP_STYLES);
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        Actions.add_feed_request ("https://blog.elementary.io/feed.xml");
    }

    public static int main (string[] args) {
        var app = new Application ();

        return app.run (args);
    }
}
