# Upgrade

A way to upgrade open-source operating systems.

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:

 - meson
 - gettext
 - libgranite-dev
 - libgtk-3-dev
 - libpolkit-gobject-1-dev
 - valac
 - python3-distupgrade

Run `meson build` to configure the build environment. Change to the build directory and run `ninja test` to build and run automated tests.

    meson build --prefix=/usr
    cd build
    ninja test

To install, use `ninja install`, then execute with `io.elementary.upgrade`.

    sudo ninja install
    io.elementary.upgrade

You can also use `--test` mode for development to disable destructive behaviors like modifying sources, installing and restarting:

    io.elementary.upgrade --test

For debug messages, set the `G_MESSAGES_DEBUG` environment variable, e.g. to `all`:

    G_MESSAGES_DEBUG=all io.elementary.upgrade
