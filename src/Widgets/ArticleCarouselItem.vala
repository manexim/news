/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Widgets.ArticleCarouselItem : Gtk.FlowBoxChild {
    public Models.Article article { get; construct set; }
    private Granite.AsyncImage icon;
    private Granite.AsyncImage source_icon;
    private Gtk.Label source_label;
    private Gtk.Box source;
    private Gtk.Label title;
    private Gtk.Label age;

    public ArticleCarouselItem (Models.Article article) {
        Object (article: article);

        get_style_context ().add_class ("entry");
    }

    construct {
        icon = new Granite.AsyncImage ();
        source_icon = new Granite.AsyncImage ();

        load_images.begin ();

        source_label = new Gtk.Label ("elementary Blog");
        source_label.halign = Gtk.Align.START;
        source_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        source = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        source.pack_start (source_icon, false, false, 0);
        source.pack_start (source_label, false, false, 8);

        title = new Gtk.Label (article.title);
        title.halign = Gtk.Align.START;
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        age = new Gtk.Label (Granite.DateTime.get_relative_datetime (article.published));
        age.halign = Gtk.Align.START;
        age.tooltip_text = "%s %s".printf (
            article.published.format (Granite.DateTime.get_default_date_format ()),
            article.published.format (Granite.DateTime.get_default_time_format ())
        );

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 3;
        grid.margin = 6;
        grid.attach (icon, 0, 0, 1, 1);
        grid.attach (source, 0, 1, 1, 1);
        grid.attach (title, 0, 2, 1, 1);
        grid.attach (age, 0, 3, 1, 1);

        add (grid);
    }

    private async void load_images () {
        var cache = Services.ImageCache.new_cache ();

        if (article.image != null) {
            string? path = null;

            int result = yield cache.fetch (article.image, out path);
            if (result == 0) {
                var file = File.new_for_path (path);

                try {
                    yield icon.set_from_file_async (file, 320, 180, true);
                    icon.halign = Gtk.Align.CENTER;
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        if (article.favicon != null) {
            string? path = null;

            int result = yield cache.fetch (article.favicon, out path);
            if (result == 0) {
                var file = File.new_for_path (path);

                try {
                    yield source_icon.set_from_file_async (file, 18, 18, false);
                    source_icon.halign = Gtk.Align.START;
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }
    }
}
