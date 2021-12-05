/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Models.Article : Object {
    public string feed_title { get; set; }
    public string url { get; set; }
    public string header_image { get; set; }
    public string title { get; set; }
    public string summary { get; set; }
    public DateTime published { get; set; }
}
