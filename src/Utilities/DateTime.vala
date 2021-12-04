/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Utilities.DateTime {
    GLib.DateTime? parse_rfc822 (string date) {
        var elements = new Gee.ArrayList<string>.wrap (date.split (" "));

        if (elements.size == 0) {
            return null;
        }

        // if there is a day of the week, remove it
        if (elements[0].length != 0 && elements[0][elements[0].length - 1] == ',') {
            elements.remove_at (0);
        }

        if (elements.size != 5) {
            return null;
        }

        var day = int.parse (elements[0]);
        int month = 1;
        switch (elements[1]) {
            case "Jan": month = 1; break;
            case "Feb": month = 2; break;
            case "Mar": month = 3; break;
            case "Apr": month = 4; break;
            case "May": month = 5; break;
            case "Jun": month = 6; break;
            case "Jul": month = 7; break;
            case "Aug": month = 8; break;
            case "Sep": month = 9; break;
            case "Oct": month = 10; break;
            case "Nov": month = 11; break;
            case "Dec": month = 12; break;
        }
        var year = int.parse (elements[2]);

        var time_arr = elements[3].split (":");
        var hour = int.parse (time_arr[0]);
        var minute = int.parse (time_arr[1]);
        var second = 0;
        if (time_arr.length >= 3) {
            second = int.parse (time_arr[2]);
        }

        TimeZone zone;
        switch (elements[4]) {
            case "EDT":
                zone = new TimeZone ("-04");
                break;
            case "EST":
            case "CDT":
                zone = new TimeZone ("-05");
                break;
            case "CST":
            case "MDT":
                zone = new TimeZone ("-06");
                break;
            case "MST":
            case "PDT":
                zone = new TimeZone ("-07");
                break;
            case "PST":
                zone = new TimeZone ("-08");
                break;
            case "1A":
                zone = new TimeZone ("-01");
                break;
            case "1M":
                zone = new TimeZone ("-12");
                break;
            case "1N":
                zone = new TimeZone ("+01");
                break;
            case "1Y":
                zone = new TimeZone ("+12");
                break;
            case "GMT":
            case "UT":
            case "1Z":
                zone = new TimeZone.utc ();
                break;
            default:
                zone = new TimeZone (elements[4]);
                break;
        }

        return new GLib.DateTime (zone, year, month, day, hour, minute, second);
    }
}
