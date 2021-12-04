/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Controllers.WebsiteController : Object {
    public Models.Website model { get; construct set; }

    public WebsiteController (Models.Website model) {
        Object (
            model: model
        );
    }
}
