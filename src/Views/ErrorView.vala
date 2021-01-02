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
    public Gtk.TextBuffer buffer { get; construct; }

    public ErrorView (Gtk.TextBuffer buffer) {
        Object (
            cancellable: true,
            buffer: buffer
        );
    }

    construct {
        var image = new Gtk.Image.from_icon_name ("dialog-error", Gtk.IconSize.DIALOG);
        image.valign = Gtk.Align.END;

        var title_label = new Gtk.Label (_("Could Not Upgrade"));
        title_label.halign = Gtk.Align.CENTER;
        title_label.max_width_chars = 60;
        title_label.valign = Gtk.Align.START;
        title_label.wrap = true;
        title_label.xalign = 0;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var description_label = new Gtk.Label (_("Upgrade to %s failed. Your device may not restart properly.").printf (Utils.get_next_pretty_name ()));
        description_label.max_width_chars = 60;
        description_label.wrap = true;
        description_label.xalign = 0;
        description_label.use_markup = true;

        var terminal_button = new Gtk.ToggleButton ();
        terminal_button.always_show_image = true;
        terminal_button.halign = Gtk.Align.START;
        terminal_button.label = _("Details");
        terminal_button.margin_top = 18;
        terminal_button.image = new Gtk.Image.from_icon_name ("utilities-terminal-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        terminal_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var terminal_view = new Upgrade.Terminal (buffer);

        var terminal_revealer = new Gtk.Revealer ();
        terminal_revealer.add (terminal_view);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.row_spacing = 6;
        grid.valign = Gtk.Align.CENTER;
        grid.add (description_label);
        grid.add (terminal_button);
        grid.add (terminal_revealer);

        content_area.column_homogeneous = true;
        content_area.halign = Gtk.Align.CENTER;
        content_area.margin = 48;
        content_area.attach (image, 0, 0);
        content_area.attach (title_label, 0, 1);
        content_area.attach (grid, 1, 0, 1, 2);

        terminal_button.toggled.connect (() => {
            terminal_revealer.reveal_child = terminal_button.active;
            if (terminal_button.active) {
                terminal_view.attempt_scroll ();
            }
        });

        show_all ();
    }
}
