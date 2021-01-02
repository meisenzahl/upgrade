/*
 * Copyright (c) 2021 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
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

public class Upgrade.StatusParser {
    private static StatusParser? instance = null;
    private Regex? regex = null;

    private StatusParser () {
        try {
            regex = new Regex ("^io\\.elementary\\.upgrade\\.([A-Z_]*):.*\\s(\\d+)%$");
        } catch (RegexError e) {
            warning (e.message);
        }
    }

    public static StatusParser get_instance () {
        if (instance == null) {
            instance = new StatusParser ();
        }

        return instance;
    }

    public bool get_status (string line, out Status status) {
        status = new Status () {
            percent = 0,
            step = Step.UNKNOWN
        };

        if (regex != null) {
            GLib.MatchInfo mi;
            if (regex.match (line, 0, out mi)) {
                status.step = Step.from_string (mi.fetch (1));
                status.percent = int.parse (mi.fetch (2));

                return (status.step != Step.UNKNOWN);
            }
        }

        return false;
    }
}
