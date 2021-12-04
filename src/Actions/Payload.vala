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

    public class AddArticle : Flux.Payload {
        public string feed { get; set; }
        public string url { get; set; }
        public string header_image { get; set; }
        public string title { get; set; }
        public string summary { get; set; }
        public DateTime published { get; set; }
    }
}
