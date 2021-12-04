/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Views.LoadingView : Gtk.Grid {
    public LoadingView (string message) {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        var label = new Gtk.Label (message);
        label.halign = Gtk.Align.CENTER;
        label.valign = Gtk.Align.CENTER;

        var spinner = new Gtk.Spinner ();
        spinner.halign = Gtk.Align.CENTER;
        spinner.valign = Gtk.Align.CENTER;
        spinner.start ();

        attach (label, 0, 0, 1, 1);
        attach (spinner, 0, 1, 1, 1);
    }
}
