/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Payload {
    public class Feed : Flux.Payload {
        public string url { get; construct set; }
    }
}
