public class Typescript.Writer {
    Valadoc.Settings settings;
    Typescript.Reporter reporter;

    private FileStream ? stream;

    public Writer (Valadoc.Settings settings, Typescript.Reporter reporter) {
        this.settings = settings;
        this.reporter = reporter;
    }

    public bool write_packages (Vala.ArrayList<Typescript.Package> packages) {
        foreach (var package in packages) {
            if (package != null && !package.is_ready ()) {
                this.reporter.simple_error ("execute", "Package is not ready!");
            }

            if (!this.write_package (package)) {
                this.close ();
                return false;
            }
        }
        this.close ();
        return true;
    }

    public bool write_package (Typescript.Package package) {
        var name = package.get_gir_package_name ();

        this.reporter.simple_note ("write package", name);

        string path = GLib.Path.build_filename (this.settings.path);
        string filepath = GLib.Path.build_filename (path, name + ".d.ts");

        DirUtils.create_with_parents (path, 0777);

        if (!this.open (filepath, "w")) {
            reporter.simple_error ("Typescript.Writer", @"Unable to open '$(filepath)' for writing");
            return false;
        }

        var sig = package.get_signature (package.root_namespace);
        this.write (sig);
        return true;
    }

    protected bool open (string filepath, string mode) {
        stream = FileStream.open (filepath, mode);
        return stream != null;
    }

    protected void close () {
        stream = null;
    }

    protected void write (string line) {
        stream.puts (line);
    }

    protected void write_line (string line) {
        stream.puts (line);
        stream.putc ('\n');
    }
}