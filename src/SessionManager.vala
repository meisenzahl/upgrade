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

namespace Upgrade {
    [DBus (name = "org.gnome.SessionManager")]
    public interface SessionManager : Object {
        public abstract async ObjectPath register_client (
            string app_id,
            string client_start_id
        ) throws DBusError, IOError;
    }

    [DBus (name = "org.gnome.SessionManager.ClientPrivate")]
    public interface SessionClient : Object {
        public abstract void end_session_response (bool is_ok, string reason) throws DBusError, IOError;

        public signal void stop () ;
        public signal void query_end_session (uint flags);
        public signal void end_session (uint flags);
        public signal void cancel_end_session ();
    }

    public static async SessionClient? register_with_session (string app_id) {
        ObjectPath? path = null;
        string? msg = null;
        string? start_id = null;

        SessionManager? session = null;
        SessionClient? session_client = null;

        start_id = Environment.get_variable ("DESKTOP_AUTOSTART_ID");
        if (start_id != null) {
            Environment.unset_variable ("DESKTOP_AUTOSTART_ID");
        } else {
            start_id = "";
            warning (
                "DESKTOP_AUTOSTART_ID not set, session registration may be broken (not running via session?)"
            );
        }

        try {
            session = yield Bus.get_proxy (
                BusType.SESSION,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager"
            );
        } catch (Error e) {
            warning ("Unable to connect to session manager: %s", e.message);
            return null;
        }

        try {
            path = yield session.register_client (app_id, start_id);
        } catch (Error e) {
            msg = e.message;
            warning ("Error registering with session manager: %s", e.message);
            return null;
        }

        try {
            session_client = yield Bus.get_proxy (BusType.SESSION, "org.gnome.SessionManager", path);
        } catch (Error e) {
            warning ("Unable to get private sessions client proxy: %s", e.message);
            return null;
        }

        return session_client;
    }
}
