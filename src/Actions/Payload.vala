/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Payload {
    public class AddFeedRequest : Flux.Payload {
        public string url { get; set; }
    }

    public class AddFeed : Flux.Payload {
        public string url { get; set; }
        public string title { get; set; }
        public string description { get; set; }
        public string website { get; set; }
        public string icon { get; set; }
    }
}
