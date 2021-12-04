/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Models.Article : Object {
    public string url { get; set; }
    public string title { get; set; }
    public string about { get; set; }
    public string content { get; set; }
    public string image { get; set; }
    public string favicon { get; set; }
    public DateTime published { get; set; }
    public DateTime updated { get; set; }
}
