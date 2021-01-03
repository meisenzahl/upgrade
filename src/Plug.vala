public class Upgrade.Plug : Switchboard.Plug {
    private Gtk.Stack empty_stack;

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
        if (empty_stack == null) {
            var alert_view = new Granite.Widgets.AlertView (
                Utils.get_pretty_name (),
                _("%s is up to date.").printf (Utils.get_name ()),
                "distributor-logo"
            );

            empty_stack = new Gtk.Stack ();
            empty_stack.add_named (alert_view, "no_tablets");

            empty_stack.show_all ();

            empty_stack.visible_child_name = "no_tablets";
        }

        return empty_stack;
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
