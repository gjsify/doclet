public class Typescript.Package : Typescript.Signable {
    protected Valadoc.Settings settings;
    // protected Typescript.GirParser gir_parser;
    protected Vala.CodeContext context;
    protected Vala.ArrayList<Typescript.Package> dependencies = new Vala.ArrayList<Typescript.Package> ();
    protected Vala.SourceFile ? source_file = null;
    public Valadoc.Api.Package package;
    public Typescript.Namespace ? current_namespace = null;
    public Gee.HashMap<string, Typescript.Class> classes = new Gee.HashMap<string, Typescript.Class> ();
    public Gee.HashMap<string, Typescript.Interface> ifaces = new Gee.HashMap<string, Typescript.Interface> ();
    public Gee.HashMap<string, Typescript.Constant> constants = new Gee.HashMap<string, Typescript.Constant> ();
    public Gee.HashMap<string, Typescript.Enum> enums = new Gee.HashMap<string, Typescript.Enum> ();
    public Gee.HashMap<string, Typescript.Struct> structs = new Gee.HashMap<string, Typescript.Struct> ();
    public Gee.HashMap<string, Typescript.Delegate> delegates = new Gee.HashMap<string, Typescript.Delegate> ();
    public Gee.HashMap<string, Typescript.ErrorDomain> error_domains = new Gee.HashMap<string, Typescript.ErrorDomain> ();
    /**
     * Global functions of this package
     */
    public Vala.ArrayList<Typescript.Method> functions = new Vala.ArrayList<Typescript.Method> ();

    public Package (Valadoc.Settings settings, Vala.CodeContext context /*, Typescript.GirParser gir_parser*/, Valadoc.Api.Package package) {
        this.settings = settings;
        this.package = package;
        this.context = context;
        // this.gir_parser = gir_parser;
        this.source_file = this.get_source_file ();
        // Use this if we need more informations from the gir files
        // this.gir_parser.load_by_package(this);
    }

    public void set_root_namespace (Typescript.Namespace ? root_namespace) {
        this.root_namespace = root_namespace;
    }

    public Typescript.Namespace ? get_root_namespace () {
        return this.root_namespace;
    }

    public bool is_ready () {
        if (this.root_namespace == null) {
            print ("root namespace is null!\n");
            return false;
        }

        if (this.source_file == null) {
            print ("source file is null!\n");
            return false;
        }
        return true;
    }

    public string get_name () {
        // return this.package.get_full_name ();
        return this.get_vala_package_name ();
    }

    public string ? get_vala_namespace () {
        if (this.root_namespace != null) {
            return this.root_namespace.vala_namespace.get_full_name ();
        }
        return null;
    }

    public string get_gir_namespace () {
        return this.source_file.gir_namespace;
    }

    public string get_gir_version () {
        return this.source_file.gir_version;
    }

    public string get_vala_package_name () {
        if (this.source_file != null) {
            return this.source_file.package_name;
        }
        // If this package is the target package, the package name is renamed by Valadoc to the target path or target package name
        if (this.is_target ()) {
            if (this.settings.source_files.length > 0) {
                if (this.settings.source_files.length > 1) {
                    print (@"WARNING: TODO Multiple source files found! $(Typescript.join(settings.source_files))\n");
                }
                var source_file_path = this.settings.source_files[0];
                var filename = GLib.Path.get_basename (source_file_path);
                var file_extension = ".vapi";
                if (filename.has_suffix (file_extension)) {
                    filename = filename.substring (0, filename.length - file_extension.length);
                }
                return filename;
            }
        }
        return this.package.get_full_name ();
    }

    public string get_gir_package_name () {
        return this.get_gir_namespace () + "-" + this.get_gir_version ();
    }

    public string get_vapi_filename () {
        if (this.source_file != null) {
            return this.source_file.filename;
        }
        return this.get_vala_package_name () + ".vapi";
    }

    public string get_gir_filename () {
        return this.get_gir_package_name () + ".gir";
    }

    public bool is_target () {
        return this.package.name == this.settings.pkg_name;
    }

    /**
     * See also https://github.com/flobrosch/valadoc-org/blob/master/src/generator.vala#L412
     */
    public string get_vapi_path () {
        string ? result = null;
        if (this.source_file != null) {
            result = this.source_file.get_relative_filename ();
        }
        if (result == null) {
            result = Typescript.get_path (this.settings.vapi_directories, this.get_vapi_filename ());
        }
        return result;
    }

    /**
     * See also https://github.com/flobrosch/valadoc-org/blob/master/src/generator.vala#L381
     */
    public string ? get_gir_path () {
        return Typescript.get_path (this.settings.gir_directories, this.get_gir_filename ());
    }

    public void add_dependency (Typescript.Package pkg) {
        if (pkg == null) {
            return;
        }
        // Do not add yourself has a dependency
        // print (@"\n\npkg.get_name: $(pkg.get_name()) -- this.get_name (): $(this.get_name ())\n\n");
        if (pkg.get_name () == this.get_name ()) {
            return;
        }

        this.dependencies.add (pkg);
    }

    public void add_dependencies (Vala.ArrayList<Typescript.Package> packages) {
        foreach (var package in packages) {
            this.add_dependency (package);
        }
    }

    public Vala.ArrayList<Typescript.Package> get_dependencies () {
        return this.dependencies;
    }

    /**
     * Specifies whether this package is a dependency
     */
    public bool is_dependency () {
        return this.package.is_package;
    }

    public bool is_main () {
        return !this.is_dependency ();
    }

    public string get_import_signature () {
        string result = @"import type * as $(this.get_gir_namespace()) from './$(this.get_gir_package_name())'; // $(this.get_vala_package_name())";
        return result;
    }

    protected Vala.SourceFile ? get_source_file () {
        var source_files = this.context.get_source_files ();
        var vapi_path = this.get_vapi_path ();
        var single_source_file = this.context.get_source_file (vapi_path);

        if (single_source_file != null) {
            return single_source_file;
        }

        foreach (var source_file in source_files) {
            if (source_file.package_name == this.package.name) {
                return source_file;
            }
        }

        return null;
    }

    /**
     * Basesd on libvaladoc/api/package.vala
     * @note You need to passt "--deps" to valadoc to get dependencies, TODO not working?
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();

        signature.append_line ("// Dependencies");
        foreach (var dependency in this.get_dependencies ()) {
            signature.append_line (dependency.get_import_signature ());
        }

        signature.append_line ("// Delegates");
        foreach (var dele in this.delegates.values) {
            signature.append_line (dele.get_signature ());
        }

        signature.append_line ("// Interfaces");
        foreach (var iface in this.ifaces.values) {
            signature.append_line (iface.get_signature ());
        }

        signature.append_line ("// Classes");
        foreach (var cls in this.classes.values) {
            signature.append_line (cls.get_signature ());
        }

        signature.append_line ("// Constants");
        foreach (var constant in this.constants.values) {
            signature.append_line (constant.get_signature ());
        }

        signature.append_line ("// Enums");
        foreach (var enm in this.enums.values) {
            signature.append_line (enm.get_signature ());
        }

        signature.append_line ("// Structs");
        foreach (var strct in this.structs.values) {
            signature.append_line (strct.get_signature ());
        }

        signature.append_line ("// Error Domains");
        foreach (var error_domain in this.error_domains.values) {
            signature.append_line (error_domain.get_signature ());
        }

        signature.append_line ("// Global functions");
        foreach (var func in this.functions) {
            signature.append_line (func.get_signature ());
        }

        return signature.to_string ();
    }
}