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

public class Views.SourcesView : Gtk.ScrolledWindow {
    public SourcesView () {
        var sources = Services.Sources.get_default ();

        var stack = new Gtk.Stack ();
        add (stack);

        var loading_view = new Views.LoadingView (
            _("Loading sources")
        );

        stack.add (loading_view);

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        stack.add (grid);

        var sources_carousel = new Widgets.SourceCarousel ();

        var sources_grid = new Gtk.Grid ();
        sources_grid.margin = 2;
        sources_grid.margin_top = 12;
        sources_grid.attach (sources_carousel, 0, 0, 1, 1);

        grid.attach (sources_grid, 0, 0, 1, 1);

        sources.added_source.connect ((source) => {
            if (stack.visible_child == loading_view) {
                stack.set_visible_child (grid);
                stack.remove (loading_view);
            }

            sources_carousel.add_source (source);
        });

        sources.update ();
    }
}
