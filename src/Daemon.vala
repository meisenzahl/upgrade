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

public class Upgrade.Daemon : GLib.Application {
    public const OptionEntry[] UPGRADE_OPTIONS = {
        { "test", 't', 0, OptionArg.NONE, out Config.test_mode, "Non-destructive test mode", null},
        { null }
    };

    private SessionClient? session_client;
    private uint registration_id = 0;

    construct {
        application_id = "io.elementary.upgrade.daemon";
        add_main_option_entries (UPGRADE_OPTIONS);
    }

    public override void activate () {
        register_with_session_manager.begin ();

        hold ();
    }

    private async bool register_with_session_manager () {
        session_client = yield register_with_session (application_id);

        session_client.query_end_session.connect (() => end_session (false));
        session_client.end_session.connect (() => end_session (false));
        session_client.stop.connect (() => end_session (true));

        return true;
    }

    public override bool dbus_register (DBusConnection connection, string object_path) throws Error {
        base.dbus_register (connection, object_path);

        try {
            registration_id = connection.register_object ("/io/elementary/upgrade/daemon", UpgradeService.get_default ());
        } catch (Error e) {
            warning (e.message);
        }

        return true;
    }

    public override void dbus_unregister (DBusConnection connection, string object_path) {
        if (registration_id != 0) {
            connection.unregister_object (registration_id);
            registration_id = 0;
        }

        base.dbus_unregister (connection, object_path);
    }

    void end_session (bool quit) {
        if (quit) {
            release ();
            return;
        }

        try {
            session_client.end_session_response (true, "");
        } catch (Error e) {
            warning ("Unable to respond to session manager: %s", e.message);
        }
    }

    public static int main (string[] args) {
        var daemon = new Daemon ();
        return daemon.run (args);
    }
}
