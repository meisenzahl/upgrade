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

    public Upgrade.Terminal terminal_view { get; construct; }
    private Gtk.ProgressBar progressbar;
    private Gtk.Label progress_label;
    private Gtk.Revealer progress_revealer;
    private Gtk.Spinner progress_spinner;
    private const int NUM_STEP = 6;

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

        var buffer = new Gtk.TextBuffer (null);
        terminal_view = new Upgrade.Terminal (buffer);

        var logo_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.OVER_UP_DOWN
        };
        logo_stack.add (logo);
        logo_stack.add (terminal_view);

        var terminal_button = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            image = new Gtk.Image.from_icon_name ("utilities-terminal-symbolic", Gtk.IconSize.SMALL_TOOLBAR)
        };
        terminal_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

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
        content_area.attach (logo_stack, 0, 0, 2, 1);
        content_area.attach (progress_grid, 0, 1, 1, 1);
        content_area.attach (terminal_button, 1, 1, 1, 1);
        content_area.attach (progressbar, 0, 2, 2, 1);

        get_style_context ().add_class ("progress-view");

        terminal_button.toggled.connect (() => {
            if (terminal_button.active) {
                logo_stack.visible_child = terminal_view;
                terminal_view.attempt_scroll ();
            } else {
                logo_stack.visible_child = logo;
            }
        });

        show_all ();
    }

    public void start_upgrade () {
        if (Upgrade.App.test_mode) {
            new Thread<void*> (null, () => {
                fake_status (Upgrade.DistUpgrade.Step.PREPARE);
                fake_status (Upgrade.DistUpgrade.Step.UPDATE_CHANNELS);
                fake_status (Upgrade.DistUpgrade.Step.DOWNLOAD);
                fake_status (Upgrade.DistUpgrade.Step.INSTALL);
                fake_status (Upgrade.DistUpgrade.Step.CLEAN_UP);
                return null;
            });
        } else {
            real_upgrade ();
        }
    }

    public void real_upgrade () {
        var upgrade = new Upgrade.DistUpgrade ();
        upgrade.on_standard_output.connect (upgrade_standard_output_callback);
        upgrade.on_standard_error.connect (upgrade_standard_error_callback);
        upgrade.on_error.connect (upgrade_error_callback);
        upgrade.on_status.connect (upgrade_status_callback);

        new Thread<void*> (null, () => {
            upgrade.upgrade ();

            return null;
        });
    }

    private void fake_status (Upgrade.DistUpgrade.Step step) {
        for (var percent = 0; percent <= 100; percent++) {
            var status = new Upgrade.DistUpgrade.Status () {
                step = step,
                percent = percent
            };
            upgrade_status_callback (status);
            GLib.Thread.usleep (10000);
        }
    }

    private void upgrade_standard_output_callback (string line) {
        terminal_view.buffer.text += line;
    }

    private void upgrade_standard_error_callback (string line) {
        Gtk.TextIter end_iter;
        terminal_view.buffer.get_end_iter (out end_iter);

        terminal_view.buffer.insert_markup (ref end_iter, "<span color=\"red\">%s</span>".printf (line), -1);
    }

    private void upgrade_status_callback (Upgrade.DistUpgrade.Status status) {
        Idle.add (() => {
            if (status.percent == 100 && status.step == Upgrade.DistUpgrade.Step.CLEAN_UP) {
                active = false;
                on_success ();
                return GLib.Source.REMOVE;
            }

            double fraction = ((double) status.percent) / (100.0 * NUM_STEP);
            switch (status.step) {
                case Upgrade.DistUpgrade.Step.PREPARE:
                    progress_label.label = _("Preparing to upgrade");
                    break;
                case Upgrade.DistUpgrade.Step.UPDATE_CHANNELS:
                    fraction += 2 * (1.0 / NUM_STEP);
                    progress_label.label = _("Setting new software channels");
                    break;
                case Upgrade.DistUpgrade.Step.DOWNLOAD:
                    fraction += 3 * (1.0 / NUM_STEP);
                    progress_label.label = _("Getting new packages");
                    break;
                case Upgrade.DistUpgrade.Step.INSTALL:
                    fraction += 4 * (1.0 / NUM_STEP);
                    progress_label.label = _("Installing the upgrades");
                    break;
                case Upgrade.DistUpgrade.Step.CLEAN_UP:
                    fraction += 5 * (1.0 / NUM_STEP);
                    progress_label.label = _("Cleaning up");
                    break;
            }

            active = true;
            //  progress_label.label += " (%d%%)".printf (status.percent); TODO: show meaningful percentage
            progressbar.fraction = fraction;
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
