public class Typescript.Class : Typescript.Signable {
    protected Valadoc.Api.Class _class;

    public Class (Typescript.Namespace ? root_namespace, Valadoc.Api.Class _class) {
        this.root_namespace = root_namespace;
        this._class = _class;
    }

    public string get_name () {
        var name = this._class.get_full_name ();
        if (this.root_namespace != null) {
            name = this.root_namespace.remove_vala_namespace (name);
            // if (name == "GLib.StringBuilder" || (root_namespace.get_vala_namespace_name () == "GLib" && name == "StringBuilder")) {
            // return "String";
            // }
        }

        if (Typescript.is_reserved_symbol_name (name)) {
            return Typescript.RESERVED_RENAME_PREFIX + name;
        }
        return name;
    }

    public bool is_abstract () {
        return this._class.is_abstract;
    }

    public bool is_sealed () {
        return this._class.is_sealed;
    }

    /**
     * Remove the Class name from a function name
     */
    public string remove_namespace (string vala_full_name) {
        return Typescript.remove_namespace (vala_full_name, this.get_name ());
    }

    protected string get_implementations (Vala.Collection<Valadoc.Api.TypeReference> interfaces) {
        var result = "";
        var first = true;
        foreach (Valadoc.Api.Item implemented_interface in interfaces) {
            if (!first) {
                result += ", ";
            }
            var ts_implemented_interface = new Typescript.TypeReference (this.root_namespace, implemented_interface as Valadoc.Api.TypeReference);
            result += ts_implemented_interface.get_signature ();
            first = false;
        }
        return result;
    }

    /**
     * Basesd on libvaladoc/api/class.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._class.accessibility.to_string (); // "public" or "private"
        var name = this.get_name ();
        var interfaces = this._class.get_implemented_interface_list ();

        if (name == "GLib.Error") {
            return "// GLib.Error";
        }

        if (interfaces.size > 0) {
            // See https://stackoverflow.com/a/54084281/1465919
            signature.append_line ("\n// For intellisense only, let's Typescript think the next class has all implementations");
            signature.append_line (@"interface $(name) extends $(this.get_implementations(interfaces)) {}");
        }

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" */\n", false);

        signature.append ("export");

        if (this.is_abstract ()) {
            signature.append_keyword ("abstract");
        }
        if (this.is_sealed ()) {
            signature.append_keyword ("/* sealed */");
        }
        signature.append_keyword ("class");
        signature.append (name);

        var type_parameters = this._class.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                var ts_param = new Typescript.TypeParameter (this.root_namespace, param as Valadoc.Api.TypeParameter);
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_content (ts_param.get_signature (), false);
                first = false;
            }
            signature.append (">", false);
        }

        //
        // Extended class
        //
        bool first = true;
        if (this._class.base_type != null) {

            signature.append ("extends");

            var ts_base_type = new Typescript.TypeReference (this.root_namespace, this._class.base_type as Valadoc.Api.TypeReference);

            signature.append_content (ts_base_type.get_signature ());
            first = false;
        }

        //
        // Implemented interfaces
        //

        if (interfaces.size > 0) {
            signature.append (@"implements $(this.get_implementations(interfaces))");
        }

        // START Body
        signature.append_content ("{\n");

        //
        // Properties
        //
        var properties = this._class.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        signature.append_line ("// Properties\n");
        foreach (var prop in properties) {
            var ts_prop = new Typescript.Property (this.root_namespace, prop as Valadoc.Api.Property);
            signature.append_content (ts_prop.get_signature ());
            signature.append (";\n", false);
        }

        //
        // Constructors
        //
        var constructors = this._class.get_children_by_types ({ Valadoc.Api.NodeType.CREATION_METHOD }, false);
        signature.append_line ("// Constructors\n");
        // Default constructor TODO add parameters
        signature.append_line ("public constructor ()\n");
        foreach (var constr in constructors) {
            var ts_constr = new Typescript.Method (this.root_namespace, constr as Valadoc.Api.Method, this, null, null, null, null);
            signature.append_content (ts_constr.get_signature ());
            signature.append (";\n", false);
        }

        //
        // Static Methods
        //
        var static_methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.STATIC_METHOD }, false);
        signature.append_line ("// Static Methods\n");
        foreach (var m in static_methods) {
            var ts_m = new Typescript.Method (this.root_namespace, m as Valadoc.Api.Method, this, null, null, null, null);
            signature.append_content (ts_m.get_signature ());
            signature.append (";\n", false);
        }

        //
        // Methods
        //
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        signature.append_line ("// Methods\n");
        foreach (var m in methods) {
            var ts_m = new Typescript.Method (this.root_namespace, m as Valadoc.Api.Method, this, null, null, null, null);
            signature.append_content (ts_m.get_signature ());
            signature.append (";\n", false);
        }

        //
        // Delegates
        //
        var delegates = this._class.get_children_by_types ({ Valadoc.Api.NodeType.DELEGATE }, false);
        signature.append_line ("// Delegates\n");
        foreach (var dele in delegates) {
            var ts_dele = new Typescript.Delegate (this.root_namespace, dele as Valadoc.Api.Delegate);
            signature.append_content (ts_dele.get_signature ());
            signature.append ("\n", false);
        }

        //
        // Signals
        //
        var signals = this._class.get_children_by_types ({ Valadoc.Api.NodeType.SIGNAL },false);
        signature.append_line ("// Signals\n");
        foreach (var sig in signals) {
            var ts_sig = new Typescript.Signal (this.root_namespace,sig as Valadoc.Api.Signal,this);
            signature.append_content (ts_sig.get_signature ());
            signature.append ("\n",false);
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}