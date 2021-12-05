/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Models.Feed : Object {
    public string url { get; construct set; }
    public string title { get; set; }
    public string description { get; set; }
    public string website { get; set; }
    public string icon { get; set; }

    public Feed (string url) {
        Object (
            url: url
        );
    }
}
