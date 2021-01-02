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
    public enum Step {
        PREPARE,
        UPDATE_CHANNELS,
        DOWNLOAD,
        INSTALL,
        CLEAN_UP
    }

    public class Status : Object {
        public int percent { get; set; default = 0; }
        public Step step { get; set; }
    }

    public signal void on_standard_output (string line);
    public signal void on_standard_error (string line);
    public signal void on_error ();
    public signal void on_status (Status status);

    public void upgrade () {
        var status = new Status () {
            step = Step.PREPARE,
            percent = 0
        };

        info ("Preparing to upgrade");
        on_status (status);
        if (!prepare ()) {
            on_error ();
            return;
        }

        status.percent = 100;
        on_status (status);

        info ("Setting new software channels");
        status.step = Step.UPDATE_CHANNELS;
        status.percent = 0;
        on_status (status);
        if (!update_channels ()) {
            on_error ();
            return;
        }

        status.percent = 100;
        on_status (status);

        info ("Getting new packages");
        status.step = Step.DOWNLOAD;
        status.percent = 0;
        on_status (status);
        if (!download ()) {
            on_error ();
            return;
        }

        status.percent = 100;
        on_status (status);

        info ("Installing the upgrades");
        status.step = Step.INSTALL;
        status.percent = 0;
        on_status (status);
        if (!install ()) {
            on_error ();
            return;
        }

        status.percent = 100;
        on_status (status);

        info ("Cleaning up");
        status.step = Step.CLEAN_UP;
        status.percent = 0;
        on_status (status);
        if (!clean_up ()) {
            on_error ();
            return;
        }

        status.percent = 100;
        on_status (status);
    }

    private static Polkit.Permission? permission = null;

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

    public bool prepare () {
        if (!authenticate ()) {
            var message = "Could not authenticate";
            warning (message);
            on_standard_error (message);
            return false;
        }

        return run ("pkexec %s/io.elementary.upgrade.helper --prepare".printf (Build.PKGDATADIR));
    }

    public bool update_channels () {
        if (!authenticate ()) {
            var message = "Could not authenticate";
            warning (message);
            on_standard_error (message);
            return false;
        }

        return run ("pkexec %s/io.elementary.upgrade.helper --update-channels --current %s --next %s".printf (Build.PKGDATADIR, Utils.get_current_channel (), Utils.get_next_channel ()));
    }

    public bool download () {
        if (!authenticate ()) {
            var message = "Could not authenticate";
            warning (message);
            on_standard_error (message);
            return false;
        }

        return run ("pkexec %s/io.elementary.upgrade.helper --download".printf (Build.PKGDATADIR));
    }

    public bool install () {
        if (!authenticate ()) {
            var message = "Could not authenticate";
            warning (message);
            on_standard_error (message);
            return false;
        }

        return run ("pkexec %s/io.elementary.upgrade.helper --install".printf (Build.PKGDATADIR));
    }

    public bool clean_up () {
        if (!authenticate ()) {
            var message = "Could not authenticate";
            warning (message);
            on_standard_error (message);
            return false;
        }

        return run ("pkexec %s/io.elementary.upgrade.helper --clean-up".printf (Build.PKGDATADIR));
    }
}
