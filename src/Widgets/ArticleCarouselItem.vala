/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Widgets.ArticleCarouselItem : Gtk.FlowBoxChild {
    public Models.Article article { get; construct set; }
    private Granite.AsyncImage header_image;
    private Gtk.Label feed_title;
    private Gtk.Label age;
    private Gtk.Label title;
    private Gtk.Label summary;

    public ArticleCarouselItem (Models.Article article) {
        Object (article: article);

        get_style_context ().add_class ("entry");
    }

    construct {
        header_image = new Granite.AsyncImage ();

        load_images.begin ();

        feed_title = new Gtk.Label ("elementary Blog");
        feed_title.halign = Gtk.Align.START;
        feed_title.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        age = new Gtk.Label (Granite.DateTime.get_relative_datetime (article.published));
        age.halign = Gtk.Align.END;
        age.tooltip_text = "%s %s".printf (
            article.published.format (Granite.DateTime.get_default_date_format ()),
            article.published.format (Granite.DateTime.get_default_time_format ())
        );

        title = new Gtk.Label (article.title);
        title.halign = Gtk.Align.START;
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        summary = new Gtk.Label (article.about);
        summary.halign = Gtk.Align.START;
        summary.ellipsize = Pango.EllipsizeMode.END;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 3;
        grid.margin = 6;
        grid.attach (header_image, 0, 0, 1, 3);
        grid.attach (feed_title, 1, 0, 1, 1);
        grid.attach (age, 2, 0, 1, 1);
        grid.attach (title, 1, 1, 2, 1);
        grid.attach (summary, 1, 2, 2, 1);

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
                    yield header_image.set_from_file_async (file, 160, 90, true);
                    header_image.halign = Gtk.Align.START;
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }
    }
}
