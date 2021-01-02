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

public abstract class AbstractUpgradeView : Gtk.Grid {
    public bool cancellable { get; construct; }
    public unowned Gtk.Widget? previous_view { get; set; }

    public signal void cancel ();

    protected Gtk.Grid content_area;
    protected Gtk.ButtonBox action_area;

    protected AbstractUpgradeView (bool cancellable = false) {
        Object (
            cancellable: cancellable,
            row_spacing: 24
        );
    }

    construct {
        content_area = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 12,
            expand = true,
            orientation = Gtk.Orientation.VERTICAL
        };

        action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            margin_end = 10,
            margin_start = 10,
            spacing = 6,
            layout_style = Gtk.ButtonBoxStyle.END
        };

        if (cancellable) {
            var cancel_button = new Gtk.Button.with_label (_("Cancel Upgrade"));
            cancel_button.clicked.connect (() => {
                cancel ();
            });

            action_area.add (cancel_button);
        }

        if (Config.test_mode) {
            var test_label = new Gtk.Label (_("Test Mode"));
            test_label.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

            action_area.add (test_label);
            action_area.set_child_non_homogeneous (test_label, true);
            action_area.set_child_secondary (test_label, true);
        }

        orientation = Gtk.Orientation.VERTICAL;
        add (content_area);
        add (action_area);
    }
}
