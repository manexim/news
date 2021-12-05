/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Services.Settings : Granite.Services.Settings {
    private static Settings settings;

    public static Settings get_default () {
        if (settings == null) {
            settings = new Settings ();
        }

        return settings;
    }

    public int window_width { get; set; }
    public int window_height { get; set; }
    public int window_x { get; set; }
    public int window_y { get; set; }
    public bool window_maximized { get; set; }

    private Settings () {
        base (Constants.APP_ID);
    }
}
