/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
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
            stderr.printf ("RegexError %s\n", e.message);
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
            stderr.printf ("RegexError %s\n", e.message);
        }

        return false;
    }

    string join (string a, string b) {
        return a.concat (b);
    }
}
