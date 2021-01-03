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

public class ProgressView : AbstractUpgradeView {
    public signal void on_success ();
    public signal void on_error ();

    private Gtk.ProgressBar progressbar;
    private Gtk.Label progress_label;
    private Gtk.Revealer progress_revealer;
    private Gtk.Spinner progress_spinner;

    private bool active {
        get {
            return progress_spinner.active;
        }
        set {
            progress_spinner.active = value;
            progress_revealer.reveal_child = value;
        }
    }

    public ProgressView () {
        Object (cancellable: false);
    }

    construct {
        var logo = new Gtk.Image () {
            icon_name = "distributor-logo",
            pixel_size = 128
        };
        logo.get_style_context ().add_class ("logo");

        progress_label = new Gtk.Label (null) {
            xalign = 0
        };
        progress_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        progressbar = new Gtk.ProgressBar () {
            hexpand = true
        };

        progress_spinner = new Gtk.Spinner ();

        progress_revealer = new Gtk.Revealer () {
            reveal_child = false,
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT
        };
        progress_revealer.add (progress_spinner);

        var progress_grid = new Gtk.Grid () {
            column_spacing = 8
        };
        progress_grid.add (progress_label);
        progress_grid.add (progress_revealer);

        content_area.margin_end = 22;
        content_area.margin_start = 22;
        content_area.attach (logo, 0, 0, 2, 1);
        content_area.attach (progress_grid, 0, 1, 1, 1);
        content_area.attach (progressbar, 0, 2, 2, 1);

        get_style_context ().add_class ("progress-view");

        show_all ();
    }

    public void start_upgrade () {
        var upgrade = UpgradeClient.get_instance ();
        upgrade.on_error.connect (upgrade_error_callback);
        upgrade.on_status.connect (upgrade_status_callback);

        new Thread<void*> (null, () => {
            try {
                upgrade.upgrade ();
            } catch (Error e) {
                upgrade_error_callback ();
                warning (e.message);
            }

            return null;
        });
    }

    private void upgrade_status_callback (Upgrade.Status status) {
        Idle.add (() => {
            if (status.percent == 100 && status.step == Upgrade.Step.CLEAN_UP) {
                active = false;
                on_success ();
                return GLib.Source.REMOVE;
            }

            switch (status.step) {
                case Upgrade.Step.PREPARE:
                    progress_label.label = _("Preparing to upgrade");
                    break;
                case Upgrade.Step.UPDATE_CHANNELS:
                    progress_label.label = _("Setting new software channels");
                    break;
                case Upgrade.Step.DOWNLOAD:
                    progress_label.label = _("Getting new packages");
                    break;
                case Upgrade.Step.INSTALL:
                    progress_label.label = _("Installing the upgrades");
                    break;
                case Upgrade.Step.CLEAN_UP:
                    progress_label.label = _("Cleaning up");
                    break;
            }

            active = true;
            progress_label.label += " (%d%%)".printf (status.percent);
            progressbar.fraction = status.percent;
            return GLib.Source.REMOVE;
        });
    }

    private void upgrade_error_callback () {
        Idle.add (() => {
            on_error ();
            return GLib.Source.REMOVE;
        });
    }
}
