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

public class Upgrade.MainWindow : Gtk.Window {
    private Gtk.Stack stack;

    private WelcomeView welcome_view;
    private WarningView warning_view;
    private ProgressView progress_view;
    private SuccessView success_view;
    private ErrorView error_view;

    public MainWindow () {
        Object (
            deletable: false,
            height_request: 700,
            icon_name: "system-os-installer",
            resizable: false,
            title: _("Upgrade %s").printf (Utils.get_name ()),
            width_request: 950
        );
    }

    construct {
        stack = new Gtk.Stack () {
            margin_bottom = 12,
            margin_top = 12,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };

        if (!Upgrade.App.test_mode && Utils.is_up_to_date ()) {
            var up_to_date_view = new UpToDateView ();

            up_to_date_view.cancel.connect (() => {
                destroy ();
            });

            stack.add (up_to_date_view);
        } else {
            welcome_view = new WelcomeView ();

            welcome_view.cancel.connect (() => {
                destroy ();
            });

            stack.add (welcome_view);

            welcome_view.next_step.connect (() => load_warning_view ());
        }

        add (stack);
    }

    private void load_warning_view () {
        if (warning_view != null) {
            warning_view.destroy ();
        }

        warning_view = new WarningView ();
        stack.add (warning_view);
        stack.visible_child = warning_view;

        warning_view.cancel.connect (() => {
            destroy ();
        });

        warning_view.next_step.connect (() => load_progress_view ());
    }

    private void load_progress_view () {
        if (progress_view != null) {
            progress_view.destroy ();
        }

        progress_view = new ProgressView ();
        stack.add (progress_view);
        stack.visible_child = progress_view;

        progress_view.on_success.connect (() => load_success_view ());

        progress_view.on_error.connect (() => {
            load_error_view (progress_view.terminal_view.buffer);
        });
        progress_view.start_upgrade ();
    }

    private void load_success_view () {
        if (success_view != null) {
            success_view.destroy ();
        }

        success_view = new SuccessView ();
        stack.add (success_view);
        stack.visible_child = success_view;
    }

    private void load_error_view (Gtk.TextBuffer buffer) {
        if (error_view != null) {
            error_view.destroy ();
        }

        error_view = new ErrorView (buffer);

        error_view.cancel.connect (() => {
            destroy ();
        });

        stack.add (error_view);
        stack.visible_child = error_view;

        error_view.previous_view = progress_view;
    }
}
