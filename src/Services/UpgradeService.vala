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
public class UpgradeService : Object {
    private Upgrade.DistUpgrade dist_upgrade;
    private bool is_upgrade_running = false;

    private static GLib.Once<UpgradeService> instance;
    public static unowned UpgradeService get_default () {
        return instance.once (() => { return new UpgradeService (); });
    }

    private UpgradeService () {
        dist_upgrade = new Upgrade.DistUpgrade ();
        dist_upgrade.on_error.connect (upgrade_error_callback);
        dist_upgrade.on_status.connect (upgrade_status_callback);
    }

    public signal void status_changed (string step, int percent);
    public signal void error ();

    public void upgrade () throws Error {
        new Thread<void*> (null, () => {
            if (!is_upgrade_running) {
                is_upgrade_running = true;
                dist_upgrade.upgrade ();
            }

            return null;
        });
    }

    private void upgrade_error_callback () {
        error ();
    }

    private void upgrade_status_callback (Upgrade.Status status) {
        status_changed (status.step.to_string (), status.percent);
    }
}
