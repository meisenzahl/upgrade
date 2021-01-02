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

public enum Upgrade.Step {
    UNKNOWN,
    PREPARE,
    UPDATE_CHANNELS,
    DOWNLOAD,
    INSTALL,
    CLEAN_UP;

    public static Step from_string (string s) {
        switch (s) {
            case "PREPARE":
                return PREPARE;
            case "UPDATE_CHANNELS":
                return UPDATE_CHANNELS;
            case "DOWNLOAD":
                return DOWNLOAD;
            case "INSTALL":
                return INSTALL;
            case "CLEAN_UP":
                return CLEAN_UP;
            case "UNKNOWN":
            default:
                return UNKNOWN;
        }
    }

    public string? to_string () {
        switch (this) {
            case UNKNOWN:
                return "UNKNOWN";
            case PREPARE:
                return "PREPARE";
            case UPDATE_CHANNELS:
                return "UPDATE_CHANNELS";
            case DOWNLOAD:
                return "DOWNLOAD";
            case INSTALL:
                return "INSTALL";
            case CLEAN_UP:
                return "CLEAN_UP";
            default:
                return null;
        }
    }
}
