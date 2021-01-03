public class Upgrade.Plug : Switchboard.Plug {
    private Gtk.Stack stack;

    private WelcomeView welcome_view;
    private WarningView warning_view;
    private ProgressView progress_view;
    private SuccessView success_view;
    private ErrorView error_view;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("system/upgrade", null);
        Object (
            category: Category.SYSTEM,
            code_name: "io.elementary.switchboard.upgrade",
            display_name: _("Upgrade"),
            description: _("Manage upgrades"),
            icon: "system-os-installer",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (stack == null) {
            stack = new Gtk.Stack () {
                margin_bottom = 12,
                margin_top = 12,
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
            };

            if (!Config.test_mode && Utils.is_up_to_date ()) {
                var up_to_date_view = new UpToDateView ();

                up_to_date_view.cancel.connect (() => {});

                stack.add (up_to_date_view);
            } else {
                load_welcome_view ();
            }

            stack.show_all ();
        }

        return stack;
    }

    private void load_welcome_view () {
        if (welcome_view != null) {
            welcome_view.destroy ();
        }

        welcome_view = new WelcomeView ();

        stack.add (welcome_view);

        welcome_view.next_step.connect (() => load_warning_view ());
    }

    private void load_warning_view () {
        if (warning_view != null) {
            warning_view.destroy ();
        }

        warning_view = new WarningView ();
        stack.add (warning_view);
        stack.visible_child = warning_view;

        warning_view.cancel.connect (() => {
            load_welcome_view ();
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
            load_welcome_view ();
        });

        stack.add (error_view);
        stack.visible_child = error_view;

        error_view.previous_view = progress_view;
    }

    public override void shown () {}

    public override void hidden () {}

    public override void search_callback (string location) {}

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );
        search_results.set ("%s → %s".printf (display_name, _("Upgrade")), "");
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Upgrade plug");
    var plug = new Upgrade.Plug ();
    return plug;
}
