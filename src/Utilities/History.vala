/*
 * Copyright 2019-2021 Manexim (https://github.com/manexim)
 * SPDX-License-Identifier: GPL-3.0-or-later
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
