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

public class Upgrade.DistUpgrade {
    public signal void on_standard_output (string line);
    public signal void on_standard_error (string line);
    public signal void on_error ();
    public signal void on_status (Status status);

    private static Polkit.Permission? permission = null;

    public void upgrade () {
        if (!authenticate ()) {
            var message = "Unable to authenticate";
            warning (message);
            on_standard_error (message);
            return;
        }

        var cmd = "upgrade";
        if (Config.test_mode) {
            cmd = "test";
        }

        Inhibitor.get_instance ().inhibit ();
        if (!run ("pkexec %s/io.elementary.upgrade.helper --%s --current %s --next %s".printf (
            Config.PKGDATADIR, cmd, Utils.get_current_channel (), Utils.get_next_channel ())
        )) {
            on_error ();
        }
        Inhibitor.get_instance ().uninhibit ();
    }

    private bool authenticate () {
        if (permission == null) {
            try {
                permission = new Polkit.Permission.sync (
                    "io.elementary.upgrade",
                    new Polkit.UnixProcess (Posix.getpid ())
                );
            } catch (Error e) {
                warning ("Can't get permission to upgrade without prompting for admin: %s", e.message);
                return false;
            }
        }

        try {
            if (!permission.allowed) {
                permission.acquire (null);
            }
        } catch (Error e) {
            warning ("Can't get permission to upgrade without prompting for admin: %s", e.message);
            return false;
        }

        return permission.allowed;
    }

    private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
        if (condition == IOCondition.HUP) {
            debug ("%s: The fd has been closed.", stream_name);
            return false;
        }

        try {
            string line;
            channel.read_line (out line, null, null);

            Status status;
            if (StatusParser.get_instance ().get_status (line, out status)) {
                on_status (status);
                return true;
            }

            switch (stream_name) {
                case "stdout":
                    debug ("%s", line);
                    on_standard_output (line);
                    break;
                case "stderr":
                    warning ("\033[0;31m%s\033[0m", line);
                    on_standard_error (line);
                    break;
            }
        } catch (IOChannelError e) {
            warning ("%s: IOChannelError: %s", stream_name, e.message);
            return false;
        } catch (ConvertError e) {
            warning ("%s: ConvertError: %s", stream_name, e.message);
            return false;
        }

        return true;
    }

    private bool run (string cmd) {
        MainLoop loop = new MainLoop ();
        try {
            string[] spawn_args = cmd.split (" ");
            string[] spawn_env = Environ.get ();
            Pid child_pid;

            int standard_input;
            int standard_output;
            int standard_error;

            bool exit_status = false;

            Process.spawn_async_with_pipes ("/",
                spawn_args,
                spawn_env,
                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                null,
                out child_pid,
                out standard_input,
                out standard_output,
                out standard_error);

            // stdout:
            IOChannel output = new IOChannel.unix_new (standard_output);
            output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition, "stdout");
            });

            // stderr:
            IOChannel error = new IOChannel.unix_new (standard_error);
            error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition, "stderr");
            });

            ChildWatch.add (child_pid, (pid, status) => {
                // Triggered when the child indicated by child_pid exits
                Process.close_pid (pid);
                exit_status = (status == 0);
                loop.quit ();
            });

            loop.run ();

            return exit_status;
        } catch (Error e) {
            warning ("Error: %s", e.message);
            return false;
        }
    }
}
