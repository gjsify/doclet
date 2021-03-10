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

    public Valadoc.Api.TypeReference ? get_base_type () {
        return this._class.base_type;
    }

    public Typescript.Class ? get_base_class () {
        var base_type = this.get_base_type ();
        if (base_type == null) {
            return null;
        }
        var base_class = base_type.data_type;
        if (base_class == null) {
            return null;
        }

        if (base_class is Valadoc.Api.Class) {
            var ts_base_class = new Typescript.Class (this.root_namespace, base_class as Valadoc.Api.Class);
            if (ts_base_class.get_name () == this.get_name ()) {
                print (@"Same name $(ts_base_class.get_name() )\n");
                return null;
            }
            return ts_base_class;
        } else {
            print (@"TODO $(base_class.get_type().name() )\n");
        }

        return null;
    }

    public Vala.ArrayList<Typescript.Method> get_methods () {
        var ts_methods = new Vala.ArrayList<Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this, null, null, null, null);
            ts_methods.add (ts_method);
        }
        return ts_methods;
    }

    public Vala.ArrayList<Typescript.Method> get_creation_methods () {
        var ts_methods = new Vala.ArrayList<Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.CREATION_METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this, null, null, null, null);
            ts_methods.add (ts_method);
        }
        return ts_methods;
    }

    public Vala.ArrayList<Typescript.Method> get_static_methods () {
        var ts_methods = new Vala.ArrayList<Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.STATIC_METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this, null, null, null, null);
            ts_methods.add (ts_method);
        }
        return ts_methods;
    }

    public Gee.HashMap<string, Typescript.Signal> get_signals () {
        var ts_signals = new Gee.HashMap<string, Typescript.Signal>();
        var signals = this._class.get_children_by_types ({ Valadoc.Api.NodeType.SIGNAL },false);
        if (signals != null && !signals.is_empty) {
            foreach (var sig in signals) {
                var ts_sig = new Typescript.Signal (this.root_namespace,sig as Valadoc.Api.Signal,this);
                ts_signals.set (ts_sig.get_name (),ts_sig);
            }
        }
        return ts_signals;
    }

    /**
     * Remove the Class name from a function name
     */
    public string remove_namespace (string vala_full_name) {
        return Typescript.remove_namespace (vala_full_name,this.get_name ());
    }

    protected Gee.HashMap<string,Typescript.Signal> get_overloaded_signals () {
        var overloaded_signals = new Gee.HashMap<string,Typescript.Signal> ();
        var class_signals = this.get_signals ();

        var ts_base_class = this.get_base_class ();
        while (ts_base_class != null) {
            print (@"base_class: $(ts_base_class.get_name())\n");
            var ts_base_signals = ts_base_class.get_signals ();
            if (ts_base_signals != null && !ts_base_signals.is_empty) {
                foreach (var ts_base_signal in ts_base_signals.values) {
                    var name = ts_base_signal.get_name ();
                    if (!class_signals.has_key (name))
                        overloaded_signals.set (name,ts_base_signal);
                }
            }
            ts_base_class = ts_base_class.get_base_class ();
        }

        return overloaded_signals;
    }

    protected string get_implementations_string (Vala.Collection<Valadoc.Api.TypeReference> interfaces) {
        var result = "";
        var first = true;
        foreach (Valadoc.Api.TypeReference implemented_interface in interfaces) {
            if (!first) {
                result += ", ";
            }
            var ts_implemented_interface = new Typescript.TypeReference (this.root_namespace,implemented_interface);
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
            signature.append_line (@"interface $(name) extends $(this.get_implementations_string(interfaces)) {}");
        }

        // TODO comments builder
        signature.append ("\n/**\n",false);
        signature.append (" * @" + accessibility + "\n",false);
        signature.append (" */\n",false);

        signature.append ("export");

        if (this.is_abstract ()) {
            signature.append_keyword ("abstract");
        }
        if (this.is_sealed ()) {
            signature.append_keyword ("/* sealed */");
        }
        signature.append_keyword ("class");
        signature.append (name);

        var type_parameters = this._class.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER,false);
        if (type_parameters.size > 0) {
            signature.append ("<",false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                var ts_param = new Typescript.TypeParameter (this.root_namespace,param as Valadoc.Api.TypeParameter);
                if (!first) {
                    signature.append (",",false);
                }
                signature.append_content (ts_param.get_signature (),false);
                first = false;
            }
            signature.append (">",false);
        }

        //
        // Extended class
        //
        bool first = true;
        if (this._class.base_type != null) {

            signature.append ("extends");

            var ts_base_type = new Typescript.TypeReference (this.root_namespace,this._class.base_type as Valadoc.Api.TypeReference);

            signature.append_content (ts_base_type.get_signature ());
            first = false;
        }

        //
        // Implemented interfaces
        //

        if (interfaces.size > 0) {
            signature.append (@"implements $(this.get_implementations_string(interfaces))");
        }

        // START Body
        signature.append_content ("{\n");

        //
        // Properties
        //
        var properties = this._class.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY },false);
        signature.append_line ("// Properties\n");
        foreach (var prop in properties) {
            var ts_prop = new Typescript.Property (this.root_namespace,prop as Valadoc.Api.Property);
            signature.append_content (ts_prop.get_signature ());
            signature.append (";\n",false);
        }

        //
        // Constructors
        //
        var ts_constructors = this.get_creation_methods ();
        signature.append_line ("// Constructors\n");
        // Default constructor TODO add parameters
        signature.append_line ("public constructor ()\n");
        foreach (var ts_constructor in ts_constructors) {
            signature.append_content (ts_constructor.get_signature ());
            signature.append (";\n",false);
        }

        //
        // Static Methods
        //
        var ts_static_methods = this.get_static_methods ();
        signature.append_line ("// Static Methods\n");
        foreach (var ts_method in ts_static_methods) {
            signature.append_content (ts_method.get_signature ());
            signature.append (";\n",false);
        }

        //
        // Methods
        //
        var ts_methods = this.get_methods ();
        signature.append_line ("// Methods\n");
        foreach (var ts_method in ts_methods) {
            signature.append_content (ts_method.get_signature ());
            signature.append (";\n",false);
        }

        //
        // Delegates
        //
        var delegates = this._class.get_children_by_types ({ Valadoc.Api.NodeType.DELEGATE },false);
        signature.append_line ("// Delegates\n");
        foreach (var dele in delegates) {
            var ts_dele = new Typescript.Delegate (this.root_namespace,dele as Valadoc.Api.Delegate);
            signature.append_content (ts_dele.get_signature ());
            signature.append ("\n",false);
        }

        //
        // Signals
        //
        var ts_signals = this.get_signals ();
        if (ts_signals.size > 0) {
            signature.append_line ("// Signals\n");
            foreach (var ts_signal in ts_signals.values) {
                signature.append_content (ts_signal.get_signature ());
                signature.append ("\n", false);
            }

            //
            // Overloaded Signals
            //
            var overloaded_ts_signals = this.get_overloaded_signals ();
            if (overloaded_ts_signals.size > 0) {
                signature.append_line ("// Overloaded Signals\n");
                foreach (var ts_signal in overloaded_ts_signals.values) {
                    signature.append_content (ts_signal.get_signature ());
                    signature.append ("\n", false);
                }
            }
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}