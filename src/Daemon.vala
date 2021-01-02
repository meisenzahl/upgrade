public class Upgrade.Daemon : GLib.Application {
    private Daemon () {}

    public static int main (string[] args) {
        var daemon = new Daemon ();
        return daemon.run (args);
    }
}
