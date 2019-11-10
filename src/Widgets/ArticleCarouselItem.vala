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

public class Widgets.ArticleCarouselItem : Gtk.FlowBoxChild {
    public Models.Article article { get; construct set; }
    private Widgets.Image icon;
    private Widgets.Image source_icon;
    private Gtk.Label source_label;
    private Gtk.Box source;
    private Gtk.Label title;
    private Gtk.Label age;

    public ArticleCarouselItem (Models.Article article) {
        Object (article: article);

        get_style_context ().add_class ("entry");
    }

    construct {
        if (article.image != null) {
            icon = article.image;
            icon.scale (320, 180);
            icon.halign = Gtk.Align.CENTER;
        } else {
            icon = new Widgets.Image ();
        }

        if (article.favicon != null) {
            source_icon = article.favicon;
            source_icon.scale_height (18);
            source_icon.halign = Gtk.Align.START;
        } else {
            source_icon = new Widgets.Image ();
        }

        source_label = new Gtk.Label (_("elementary Blog"));
        source_label.halign = Gtk.Align.START;
        source_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        source = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        source.pack_start (source_icon, false, false, 0);
        source.pack_start (source_label, false, false, 8);

        title = new Gtk.Label (article.title);
        title.halign = Gtk.Align.START;
        title.get_style_context ().add_class ("h2");

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
}
