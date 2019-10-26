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

public class Utilities.History {
    private Gee.LinkedList<string> list;
    private int index = -1;

    public History () {
        list = new Gee.LinkedList<string> ();
    }

    public bool is_homepage {
        get {
            return list.size <= 1;
        }
    }

    public string current {
        owned get {
            return list.get (index);
        }
    }

    public string previous {
        owned get {
            return list.get (index - 1);
        }
    }

    public void add (string v) {
        list.add (v);
        index += 1;
    }

    public string pop () {
        index -= 1;
        return list.poll_tail ();
    }

    public void println () {
        print ("History: ");
        for (int i = 0; i < list.size; i++) {
            print (list.get (i));

            if (i < list.size - 1) {
                print (" > ");
            }
        }

        print ("\n");
    }
}
