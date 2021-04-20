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

public class UpgradeClient : Object {
    public signal void on_status (Upgrade.Status status);
    public signal void on_error ();

    private UpgradeInterface interface;

    static UpgradeClient? instance = null;
    public static UpgradeClient get_instance () {
        if (instance == null) {
            instance = new UpgradeClient ();
        }

        return instance;
    }

    public void upgrade () throws Error {
        interface.upgrade ();
    }

    private UpgradeClient () {}

    construct {
        try {
            interface = Bus.get_proxy_sync (BusType.SESSION, "io.elementary.update.daemon", "/io/elementary/update.daemon", DBusProxyFlags.NONE);

            interface.status_changed.connect ((step, percent) => {
                on_status (new Upgrade.Status () {
                    step = Upgrade.Step.from_string (step),
                    percent = percent
                });
            });
            interface.error.connect (() => { on_error (); });
        } catch (Error e) {
            warning ("Could not connect to prefers color scheme settings: %s", e.message);
        }
    }
}
