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

public class ErrorView : AbstractUpgradeView {

    public ErrorView () {
        Object (
            cancellable: true
        );
    }

    construct {
        var image = new Gtk.Image.from_icon_name ("dialog-error", Gtk.IconSize.DIALOG) {
            valign = Gtk.Align.END
        };

        var title_label = new Gtk.Label (_("Could Not Upgrade")) {
            halign = Gtk.Align.CENTER,
            max_width_chars = 60,
            valign = Gtk.Align.START,
            wrap = true,
            xalign = 0
        };
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var description_label = new Gtk.Label (_("Upgrade to %s failed. Your device may not restart properly.").printf (Utils.get_next_pretty_name ())) {
            max_width_chars = 60,
            wrap = true,
            xalign = 0,
            use_markup = true
        };

        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 6,
            valign = Gtk.Align.CENTER
        };
        grid.add (description_label);

        content_area.column_homogeneous = true;
        content_area.halign = Gtk.Align.CENTER;
        content_area.margin = 48;
        content_area.attach (image, 0, 0);
        content_area.attach (title_label, 0, 1);
        content_area.attach (grid, 1, 0, 1, 2);

        show_all ();
    }
}
