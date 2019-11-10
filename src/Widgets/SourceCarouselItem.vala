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

public class Widgets.SourceCarouselItem : Gtk.FlowBoxChild {
    public Models.Feed source { get; construct set; }
    private Granite.AsyncImage source_icon;
    private Gtk.Label source_label;
    private Gtk.Box source_box;

    public SourceCarouselItem (Models.Feed source) {
        Object (source: source);

        get_style_context ().add_class ("entry");
    }

    construct {
        source_icon = new Granite.AsyncImage ();

        load_images.begin ();

        source_label = new Gtk.Label (source.title);
        source_label.halign = Gtk.Align.START;
        source_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var source_switch = new Gtk.Switch ();
        source_switch.active = source.subscribed;
        source_switch.bind_property ("active", source, "subscribed");
        source_switch.sensitive = false;

        source_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        source_box.pack_start (source_switch, false, false, 8);
        source_box.pack_start (source_icon, false, false, 0);
        source_box.pack_start (source_label, false, false, 8);

        var description_label = new Gtk.Label (source.description);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 3;
        grid.margin = 6;
        grid.attach (source_box, 0, 0, 1, 1);
        grid.attach (description_label, 0, 1, 1, 1);

        add (grid);
    }

    private async void load_images () {
        var cache = Services.ImageCache.new_cache ();

        if (source.favicon != null) {
            string? path = null;

            int result = yield cache.fetch (source.favicon, out path);
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
