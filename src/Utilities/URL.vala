/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Utilities.URL {
    string? base (string url) {
        try {
            Regex regex = new Regex ("(.*://[^/]*)/.*");
            MatchInfo mi;
            var match = regex.match (url, 0, out mi);
            if (match) {
                return mi.fetch (1);
            }
        } catch (RegexError e) {
            warning ("RegexError %s\n", e.message);
        }

        return null;
    }

    bool is_absolute (string url) {
        try {
            Regex regex = new Regex ("(.*://.*)/.*");
            var match = regex.match (url);
            if (match) {
                return true;
            }
        } catch (RegexError e) {
            warning ("RegexError %s\n", e.message);
        }

        return false;
    }

    string join (string a, string b) {
        return a.concat (b);
    }
}
