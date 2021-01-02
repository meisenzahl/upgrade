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

[DBus (name="io.elementary.upgrade")]
public class DBusServer : Object {
    private static GLib.Once<DBusServer> instance;
    public static unowned DBusServer get_default () {
        return instance.once (() => { return new DBusServer (); });
    }

    public signal void status_changed (string step, int percent);

    public signal void error ();

    public void upgrade () throws Error {
        var upgrade = new Upgrade.DistUpgrade ();
        upgrade.on_error.connect (upgrade_error_callback);
        upgrade.on_status.connect (upgrade_status_callback);

        upgrade.upgrade ();
    }

    private void upgrade_error_callback () {
        error ();
    }

    private void upgrade_status_callback (Upgrade.Status status) {
        status_changed (status.step.to_string (), status.percent);
    }
}
