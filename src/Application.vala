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

public class Upgrade.App : Gtk.Application {
    public const OptionEntry[] UPGRADE_OPTIONS = {
        { "test", 't', 0, OptionArg.NONE, out App.test_mode, "Non-destructive test mode", null},
        { null }
    };

    public static bool test_mode;

    construct {
        application_id = "io.elementary.upgrade";
        flags = ApplicationFlags.FLAGS_NONE;
        Intl.setlocale (LocaleCategory.ALL, "");
        add_main_option_entries (UPGRADE_OPTIONS);
    }

    public override void activate () {
        var window = new MainWindow ();
        window.show_all ();
        this.add_window (window);

        Inhibitor.get_instance ().inhibit ();
    }
}

public static int main (string[] args) {
    var application = new Upgrade.App ();
    return application.run (args);
}
