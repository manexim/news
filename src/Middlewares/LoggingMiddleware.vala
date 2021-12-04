/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class LoggingMiddleware : Flux.Middleware {
    public override void process (Flux.Action action) {
        debug ("%s: %s", action.action_type, Json.gobject_to_data (action.payload, null));
    }
}
