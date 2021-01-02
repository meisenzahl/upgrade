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

namespace Utils {
    public static string? get_os_info (string key_name) {
        var file = File.new_for_path ("/etc/os-release");
        try {
            var dis = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null) {
                var parts = line.split ("=", 2);
                if (parts.length == 2) {
                    var key = parts[0];
                    var value = parts[1].replace ("\"", "");

                    if (key == key_name) {
                        return value;
                    }
                }
            }
        } catch (Error e) {
            warning ("Couldn't read os-release file");
        }

        return null;
    }

    public static string? get_name () {
        return get_os_info ("NAME");
    }

    public static string? get_next_pretty_name () {
        if (Config.test_mode) {
            return "%s Next".printf (get_name ());
        }

        switch (get_os_info ("VERSION_CODENAME")) {
            case "jupyter":
                return "%s Luna".printf (get_name ());
            case "luna":
                return "%s Freya".printf (get_name ());
            case "freya":
                return "%s Loki".printf (get_name ());
            case "loki":
                return "%s Hera".printf (get_name ());
            case "juno":
            case "hera":
                return "%s Odin".printf (get_name ());
        }

        return null;
    }

    public static string? get_current_channel () {
        switch (get_os_info ("VERSION_CODENAME")) {
            case "jupyter":
                return "maverick";
            case "luna":
                return "precise";
            case "freya":
                return "trusty";
            case "loki":
                return "xenial";
            case "juno":
            case "hera":
                return "bionic";
        }

        return null;
    }

    public static string? get_next_channel () {
        switch (get_os_info ("VERSION_CODENAME")) {
            case "jupyter":
                return "precise";
            case "luna":
                return "trusty";
            case "freya":
                return "xenial";
            case "loki":
                return "bionic";
            case "juno":
            case "hera":
                return "focal";
        }

        return null;
    }

    public static string? get_pretty_name () {
        var pretty_name = get_os_info ("PRETTY_NAME");
        if (pretty_name == "" || pretty_name == null) {
            pretty_name = get_os_info ("NAME");
        }

        return pretty_name;
    }

    public static bool is_up_to_date () {
        return get_next_channel () == null;
    }

    private static void restart () {
        if (Config.test_mode) {
            critical (_("Test mode reboot"));
            Process.exit (0);
        } else {
            get_system_instance ();

            try {
                system_instance.reboot (false);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }
    }

    [DBus (name = "org.freedesktop.login1.Manager")]
    interface SystemInterface : Object {
        public abstract void reboot (bool interactive) throws GLib.Error;
    }

    private static SystemInterface? system_instance;
    private static void get_system_instance () {
        if (system_instance == null) {
            try {
                system_instance = Bus.get_proxy_sync (
                    BusType.SYSTEM,
                    "org.freedesktop.login1",
                    "/org/freedesktop/login1"
                );
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }
}
