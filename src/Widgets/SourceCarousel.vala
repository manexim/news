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

public class Widgets.SourceCarousel : Gtk.FlowBox {
    public signal void on_article_activated (Models.Feed source);

    public SourceCarousel () {
        Object (
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
    }

    public void add_source (Models.Feed? source) {
        var carousel_item = new SourceCarouselItem (source);
        add (carousel_item);
        unselect_child (carousel_item);
        show_all ();
    }
}
