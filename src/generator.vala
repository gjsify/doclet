public class Typescript.Generator : Valadoc.Api.Visitor {

    protected Typescript.Reporter reporter;
    protected Valadoc.Settings settings;
    protected Valadoc.Api.Tree current_tree;
    protected Typescript.GirParser gir_parser;

    protected Typescript.Package ? current_dependency_package = null;
    protected Typescript.Package ? current_main_package = null;
    protected Typescript.Class ? current_class = null;
    protected Typescript.Interface ? current_interface = null;
    protected Typescript.Struct ? current_struct = null;
    protected Typescript.Enum ? current_enum = null;
    protected Typescript.ErrorDomain ? current_error_domain = null;

    /**
     * Normally for GObject and GLib
     */
    protected Vala.ArrayList<Typescript.Package> general_dependencies = new Vala.ArrayList<Typescript.Package> ();
    protected Vala.ArrayList<Typescript.Package> main_packages = new Vala.ArrayList<Typescript.Package> ();

    public bool execute (Valadoc.Settings settings, Valadoc.Api.Tree tree, Typescript.Reporter reporter, Typescript.GirParser gir_parser) {
        this.settings = settings;
        this.reporter = reporter;
        this.current_tree = tree;
        this.gir_parser = gir_parser;

        tree.accept (this);

        foreach (var main_package in this.main_packages) {
            if (main_package != null && !main_package.is_ready ()) {
                this.reporter.simple_error ("execute", "Package is not ready!");
            }

            var name = main_package.get_gir_package_name ();

            this.reporter.simple_note ("write package", name);

            string path = GLib.Path.build_filename (this.settings.path);
            string filepath = GLib.Path.build_filename (path, name + ".d.ts");

            DirUtils.create_with_parents (path, 0777);

            var writer = new Typescript.Writer (filepath, "a+");
            if (!writer.open ()) {
                reporter.simple_error ("Typescript", "unable to open '%s' for writing", writer.filename);
                return false;
            }

            var sig = main_package.get_signature (main_package.root_namespace);
            writer.write (sig);
        }

        // this.reporter.simple_note("execute", "execute: %s", (string) this.settings);
        return true;
    }

    /**
     * Visit operation called for api trees.
     *
     * @param item a tree
     */
    public override void visit_tree (Valadoc.Api.Tree tree) {
        this.reporter.simple_note ("visit_tree START", "");
        tree.accept_children (this);
        // END
        this.reporter.simple_note ("visit_tree END", "");
        this.current_main_package = null;
        this.current_dependency_package = null;
    }

    /**
     * Visit operation called for packages like gir-files and vapi-files.
     *
     * @param item a package
     */
    public override void visit_package (Valadoc.Api.Package package) {
        if (package == null) {
            return;
        }

        var ts_package = new Typescript.Package (this.settings, this.current_tree.context, this.gir_parser, package);

        if (ts_package.is_main ()) {
            this.visit_main_package (ts_package);
        } else if (ts_package.is_dependency ()) {
            this.visit_dependency_package (ts_package);
        } else {
            this.reporter.simple_error ("visit_package", "Package is not a main package and not a dependency!");
        }
    }

    public void visit_main_package (Typescript.Package ts_package) {
        // START
        this.reporter.simple_note ("visit_main_package START", ts_package.get_name ());
        this.current_main_package = ts_package;
        ts_package.package.accept_all_children (this);

        // END
        this.reporter.simple_note ("visit_main_package END", ts_package.get_name ());
        this.main_packages.add (this.current_main_package);
    }

    public void visit_dependency_package (Typescript.Package ts_package) {
        this.current_dependency_package = ts_package;

        // Uncomment this if you also want to visit the childs of the dependencies like the classes. interfaces etc
        // package.accept_all_children (this);

        if (this.current_main_package == null) {
            // GObject or GLib
            this.general_dependencies.add (this.current_dependency_package);
        } else {
            this.current_main_package.add_dependency (this.current_dependency_package);
        }
    }

    /**
     * Visit operation called for namespaces
     *
     * @param item a namespace
     */
    public override void visit_namespace (Valadoc.Api.Namespace ns) {

        // Is global namespace?
        if (ns.name == null) {
            ns.accept_all_children (this);
            return;
        }

        if (!ns.is_browsable (this.settings)) {
            return;
        }

        // Resets


        this.reporter.simple_note ("visit_namespace START", ns.get_full_name ());

        var ts_namespace = new Typescript.Namespace (ns, this.current_main_package);
        this.current_main_package.current_namespace = ts_namespace;
        if (this.current_main_package.root_namespace == null && ts_namespace.is_root ()) {
            this.current_main_package.root_namespace = ts_namespace;
        }

        ns.accept_all_children (this);

        // if (ns != null && ns.get_full_name () != null) {

        // }

        this.reporter.simple_note ("visit_namespace END", ns.get_full_name ());
    }

    /**
     * Visit operation called for interfaces.
     *
     * @param item a interface
     */
    public override void visit_interface (Valadoc.Api.Interface iface) {
        // this.reporter.simple_note("visit_interface", iface.get_full_name());

        var ts_iface = new Typescript.Interface (iface);
        this.current_interface = ts_iface;
        this.current_main_package.ifaces.add (ts_iface);

        iface.accept_all_children (this);

        var abstract_methods = iface.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var m in abstract_methods) {
            // List all protected methods, even if they're not marked as browsable
            if (m.is_browsable (this.settings) || ((Valadoc.Api.Symbol)m).is_protected) {
                this.visit_abstract_method ((Valadoc.Api.Method)m);
            }
        }

        var abstract_properties = iface.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        foreach (var prop in abstract_properties) {
            // List all protected properties, even if they're not marked as browsable
            if (prop.is_browsable (this.settings) || ((Valadoc.Api.Symbol)prop).is_protected) {
                this.visit_abstract_property ((Valadoc.Api.Property)prop);
            }
        }

        // END
        this.current_interface = null;

        // var ts_iface = new Typescript.Interface(iface);
        // var sig = ts_iface.get_signature();
        // this.reporter.simple_note("visit_interface", @"$(sig)");
    }

    /**
     * Visit operation called for classes.
     *
     * @param item a class
     */
    public override void visit_class (Valadoc.Api.Class cl) {
        this.reporter.simple_note ("visit_class START", cl.name);

        var ts_class = new Typescript.Class (cl);
        this.current_class = ts_class;
        this.current_main_package.classes.add (ts_class);

        cl.accept_all_children (this);

        var abstract_methods = cl.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var m in abstract_methods) {
            // List all protected methods, even if they're not marked as browsable
            if (m.is_browsable (settings) || ((Valadoc.Api.Symbol)m).is_protected) {
                visit_abstract_method ((Valadoc.Api.Method)m);
            }
        }

        var abstract_properties = cl.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        foreach (var prop in abstract_properties) {
            // List all protected properties, even if they're not marked as browsable
            if (prop.is_browsable (settings) || ((Valadoc.Api.Symbol)prop).is_protected) {
                visit_abstract_property ((Valadoc.Api.Property)prop);
            }
        }

        // END
        this.reporter.simple_note ("visit_class END", cl.name);

        this.current_class = null;
    }

    /**
     * Visit operation called for structs.
     *
     * @param item a struct
     */
    public override void visit_struct (Valadoc.Api.Struct st) {
        this.reporter.simple_note ("visit_struct START", st.name);
        var ts_struct = new Typescript.Struct (st);
        this.current_struct = ts_struct;
        st.accept_all_children (this);
        this.reporter.simple_note ("visit_struct END", st.name);
        this.current_struct = null;
    }

    /**
     * Visit operation called for properties.
     *
     * @param item a property
     */
    public override void visit_property (Valadoc.Api.Property prop) {
        // this.reporter.simple_note("visit_property", "visit_property: %s", (string) prop.name);
        // this.reporter.simple_note("visit_property", @"$(prop.name), ");
        prop.accept_all_children (this);
    }

    /**
     * Visit operation called for fields.
     *
     * @param item a field
     */
    public override void visit_field (Valadoc.Api.Field f) {
        // this.reporter.simple_note("visit_field", "visit_field: %s", (string) f.name);
        f.accept_all_children (this);
    }

    /**
     * Visit operation called for constants.
     *
     * @param item a constant
     */
    public override void visit_constant (Valadoc.Api.Constant cons) {
        var ts_cons = new Typescript.Constant (cons as Valadoc.Api.Constant);
        this.current_main_package.constants.add (ts_cons);
        cons.accept_all_children (this);
    }

    /**
     * Visit operation called for delegates.
     *
     * @param item a delegate
     */
    public override void visit_delegate (Valadoc.Api.Delegate dele) {
        this.reporter.simple_note ("visit_delegate START", dele.name);
        dele.accept_children ({ Valadoc.Api.NodeType.FORMAL_PARAMETER, Valadoc.Api.NodeType.TYPE_PARAMETER }, this);
        this.reporter.simple_note ("visit_delegate END", dele.name);
    }

    /**
     * Visit operation called for signals.
     *
     * @param item a signal
     */
    public override void visit_signal (Valadoc.Api.Signal sig) {
        this.reporter.simple_note ("visit_signal START", sig.name);
        sig.accept_all_children (this);
        this.reporter.simple_note ("visit_signal END", sig.name);
    }

    /**
     * Visit operation called for methods.
     *
     * @param item a method
     */
    public override void visit_method (Valadoc.Api.Method m) {
        // this.reporter.simple_note("visit_method", "visit_method: %s", (string) m.name);
        // m.accept_children ({NodeType.FORMAL_PARAMETER, NodeType.TYPE_PARAMETER}, this);

        var ts_m = new Typescript.Method (m as Valadoc.Api.Method, this.current_class, this.current_interface, this.current_struct, this.current_enum, this.current_error_domain);


        if (m.is_constructor) {
            this.visit_constructor (ts_m);
        }

        if (ts_m.is_global (this.current_main_package.root_namespace)) {
            this.visit_global_function (ts_m);
        }

        m.accept_all_children (this);
        // this.reporter.simple_note("visit_method", @"): $(m.return_type.data.type_name)");
    }

    public void visit_static_method (Valadoc.Api.Method m) {
        // this.reporter.simple_note("visit_static_method START", m.name);
        m.accept_all_children (this);
    }

    public void visit_constructor (Typescript.Method ts_method) {
        // this.reporter.simple_note("visit_constructor START", m.name);
    }

    /**
     * Global functions
     */
    public void visit_global_function (Typescript.Method ts_method) {
        this.reporter.simple_note ("visit_global_function", ts_method.get_name (this.current_main_package.root_namespace));
        this.current_main_package.functions.add (ts_method);
    }

    /**
     * Visit operation called for type parameters.
     *
     * @param item a type parameter
     */
    public override void visit_type_parameter (Valadoc.Api.TypeParameter param) {
        // this.reporter.simple_note("visit_type_parameter", "visit_type_parameter: %s", (string) param.name);
        if (param.name != null) {
            // this.reporter.simple_note("visit_type_parameter", @" $(param.data.type_name),");
        }

        param.accept_all_children (this);
    }

    /**
     * Visit operation called for parameters.
     *
     * @param item a parameter
     */
    public override void visit_formal_parameter (Valadoc.Api.Parameter param) {
        // this.reporter.simple_note("visit_formal_parameter", "visit_formal_parameter: %s", (string) param.name);
        if (param.name != null) {
            // this.reporter.simple_note("visit_formal_parameter", @" $(param.name): $(param.data.type_name)");
        }

        param.accept_all_children (this);
    }

    /**
     * Visit operation called for error domains.
     *
     * @param item a error domain
     */
    public override void visit_error_domain (Valadoc.Api.ErrorDomain error_domain) {
        this.reporter.simple_note ("visit_error_domain START", error_domain.name);
        var ts_error_domain = new Typescript.ErrorDomain (error_domain);
        this.current_error_domain = ts_error_domain;
        if (this.current_main_package != null) {
            this.current_main_package.error_domains.add (ts_error_domain);
        } else {
            this.reporter.simple_error ("visit_error_domain", "Package for error domain not found!");
        }
        error_domain.accept_all_children (this);
        this.reporter.simple_note ("visit_error_domain END", error_domain.name);
    }

    /**
     * Visit operation called for error codes.
     *
     * @param item a error code
     */
    public override void visit_error_code (Valadoc.Api.ErrorCode ecode) {
        // this.reporter.simple_note("visit_error_code", "visit_error_code: %s", (string) ecode.name);
        ecode.accept_all_children (this);
    }

    /**
     * Visit operation called for enums.
     *
     * @param item a enum
     */
    public override void visit_enum (Valadoc.Api.Enum en) {
        var is_global = this.current_class == null && this.current_interface == null && this.current_struct == null;
        var ts_enum = new Typescript.Enum (en);
        this.current_enum = ts_enum;

        if (is_global) {
            this.visit_global_enum (ts_enum);
        } else {
            this.reporter.simple_note ("visit_enum START", en.name);
        }

        en.accept_all_children (this);

        if (!is_global) {
            this.reporter.simple_note ("visit_enum END", en.name);
        }


        this.current_enum = null;
    }

    /**
     * Visit operation called for enum values.
     *
     * @param item a enum value
     */
    public override void visit_enum_value (Valadoc.Api.EnumValue eval) {
        // this.reporter.simple_note("visit_enum_value", "visit_enum_value: %s", (string) eval.name);
        eval.accept_all_children (this);
    }

    public void visit_global_enum (Typescript.Enum ts_enum) {
        this.reporter.simple_note ("visit_global_enum START", ts_enum.get_name (this.current_main_package.root_namespace));
        this.current_main_package.enums.add (ts_enum);
        this.reporter.simple_note ("visit_global_enum END", ts_enum.get_name (this.current_main_package.root_namespace));
    }

    /**
     * Visit abstract methods
     */
    protected void visit_abstract_method (Valadoc.Api.Method m) {
        // this.reporter.simple_note("visit_abstract_method", @"abstract $(m.name)");
        if (!m.is_static && !m.is_constructor) {
            // this.reporter.simple_note("visit_abstract_method", @"$(m.name) (");
            m.accept_all_children (this);
            // this.reporter.simple_note("visit_abstract_method", @"): $(m.return_type.data.type_name)");
        }
    }

    /**
     * Visit abstract properties
     */
    protected void visit_abstract_property (Valadoc.Api.Property prop) {
        // this.reporter.simple_note("visit_abstract_property", "visit_abstract_property: %s", (string) prop.name);
        prop.accept_all_children (this);
    }
}