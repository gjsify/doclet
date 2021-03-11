public enum KeyType {
    NAME,
    SIGNATURE
}

public class Typescript.Class : Typescript.Signable {
    protected Valadoc.Api.Class _class;

    public Class (Typescript.Namespace ? root_namespace, Valadoc.Api.Class _class) {
        this.root_namespace = root_namespace;
        this._class = _class;
    }

    public override string get_name () {
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
                print (@"Same name $(ts_base_class.get_name ())\n");
                return null;
            }
            return ts_base_class;
        } else {
            print (@"TODO $(base_class.get_type ().name ())\n");
        }

        return null;
    }

    public Gee.HashMap<string, Typescript.Method> get_methods (bool only_public = true, KeyType key_type = KeyType.SIGNATURE) {
        var ts_methods = new Gee.HashMap<string, Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this);
            if (ts_method.is_public ()) {
                string key = key_type == KeyType.SIGNATURE ? ts_method.get_signature () : ts_method.get_name ();
                ts_methods.set (key, ts_method);
            }
        }
        return ts_methods;
    }

    public Gee.HashMap<string, Typescript.Method> get_creation_methods (bool only_public = true, KeyType key_type = KeyType.SIGNATURE) {
        var ts_methods = new Gee.HashMap<string, Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.CREATION_METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this);
            if (ts_method.is_public ()) {
                string key = key_type == KeyType.SIGNATURE ? ts_method.get_signature () : ts_method.get_name ();
                ts_methods.set (key, ts_method);
            }
        }
        return ts_methods;
    }

    public Gee.HashMap<string, Typescript.Method> get_static_methods (bool only_public = true, KeyType key_type = KeyType.SIGNATURE) {
        var ts_methods = new Gee.HashMap<string, Typescript.Method>();
        var methods = this._class.get_children_by_types ({ Valadoc.Api.NodeType.STATIC_METHOD }, false);
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, this);
            if (ts_method.is_public ()) {
                string key = key_type == KeyType.SIGNATURE ? ts_method.get_signature () : ts_method.get_name ();
                ts_methods.set (key, ts_method);
            }
        }
        return ts_methods;
    }

    public Gee.HashMap<string, Typescript.Signal> get_signals (KeyType key_type = KeyType.SIGNATURE) {
        var ts_signals = new Gee.HashMap<string, Typescript.Signal>();
        var signals = this._class.get_children_by_types ({ Valadoc.Api.NodeType.SIGNAL },false);
        if (signals != null && !signals.is_empty) {
            foreach (var sig in signals) {
                var ts_sig = new Typescript.Signal (this.root_namespace,sig as Valadoc.Api.Signal,this);
                string key = key_type == KeyType.SIGNATURE ? ts_sig.get_signature () : ts_sig.get_name ();
                ts_signals.set (key,ts_sig);
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

    protected GLib.List<Typescript.Method> find_methods_in_base_classes_by_name (string name,Typescript.Class related_class,bool only_public = true) {
        var results = new GLib.List<Typescript.Method>();
        var current_class = this; // Start on current class

        while (current_class != null) {
            if (current_class.get_name () != related_class.get_name ()) {
                var ts_base_methods = current_class.get_methods (only_public,KeyType.NAME);
                if (ts_base_methods != null && !ts_base_methods.is_empty) {
                    foreach (var ts_base_method in ts_base_methods.values) {
                        var base_name = ts_base_method.get_name ();
                        if (base_name == name) {
                            results.append (ts_base_method);
                        }
                    }
                }
            }
            current_class = current_class.get_base_class ();
        }
        return results;
    }

    protected Gee.HashMap<string,Typescript.Method> get_missing_overloaded_methods (bool only_public = true,uint deep = 1) {
        var overloaded_methods = new Gee.HashMap<string,Typescript.Method> ();
        var current_class = this; // Start on current class

        while (current_class != null) {
            var ts_base_methods = current_class.get_methods (only_public,KeyType.NAME);
            if (ts_base_methods != null && !ts_base_methods.is_empty) {
                foreach (var ts_base_method in ts_base_methods.values) {
                    var name = ts_base_method.get_name ();
                    var found_methods_with_same_name = this.find_methods_in_base_classes_by_name (name,current_class,only_public);

                    foreach (var found_method in found_methods_with_same_name) {
                        var signature = ts_base_method.get_signature ();
                        overloaded_methods.set (signature,ts_base_method);
                    }
                }
            }
            current_class = current_class.get_base_class ();
        }

        return overloaded_methods;
    }

    protected Gee.HashMap<string,Typescript.Signal> get_missing_overloaded_signals (KeyType key_type = KeyType.SIGNATURE) {
        var overloaded_signals = new Gee.HashMap<string,Typescript.Signal> ();
        var class_signals = this.get_signals (key_type);
        var ts_base_class = this.get_base_class ();

        while (ts_base_class != null) {
            var ts_base_signals = ts_base_class.get_signals (key_type);
            if (ts_base_signals != null && !ts_base_signals.is_empty) {
                foreach (var ts_base_signal in ts_base_signals.values) {
                    var key = key_type == KeyType.SIGNATURE ? ts_base_signal.get_signature () : ts_base_signal.get_name ();
                    if (!class_signals.has_key (key))
                        overloaded_signals.set (key,ts_base_signal);
                }
            }
            ts_base_class = ts_base_class.get_base_class ();
        }

        return overloaded_signals;
    }

    protected Gee.HashMap<string,Typescript.Method> get_missing_overloaded_creation_methods (bool only_public = true,KeyType key_type = KeyType.SIGNATURE) {
        var overloaded_creation_methods = new Gee.HashMap<string,Typescript.Method> ();
        var class_creation_methods = this.get_creation_methods (only_public,key_type);
        var ts_base_class = this.get_base_class ();

        while (ts_base_class != null) {
            var ts_base_creation_methods = ts_base_class.get_creation_methods (only_public,key_type);
            if (ts_base_creation_methods != null && !ts_base_creation_methods.is_empty) {
                foreach (var ts_base_constructor in ts_base_creation_methods.values) {
                    var key = key_type == KeyType.SIGNATURE ? ts_base_constructor.get_signature () : ts_base_constructor.get_name ();
                    if (!class_creation_methods.has_key (key))
                        overloaded_creation_methods.set (key,ts_base_constructor);
                }
            }
            ts_base_class = ts_base_class.get_base_class ();
        }

        return overloaded_creation_methods;
    }

    protected string get_implementations_str (Vala.Collection<Valadoc.Api.TypeReference> interfaces) {
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

    public string get_type_parameter_signature () {
        var result = "";
        var type_parameters = this._class.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER,false);
        if (type_parameters.size > 0) {
            result += "<";
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                var ts_param = new Typescript.TypeParameter (this.root_namespace,param as Valadoc.Api.TypeParameter);
                if (!first) {
                    result += ", ";
                }
                result += ts_param.get_signature ();
                first = false;
            }
            result += ">";
        }
        return result;
    }

    /**
     * Used to simulare multiple inheritance
     * @see https://stackoverflow.com/a/54084281/1465919
     */
    protected string build_inheritance_interface_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var interfaces = this._class.get_implemented_interface_list ();
        var ts_base_class = this.get_base_class ();
        var name = this.get_name ();

        if (interfaces.size > 0 || ts_base_class != null) {
            signature.append_line ("\n// For intellisense only, let's Typescript think the next class has all implementations");
            signature.append_line (@"interface $(name)");

            if (interfaces.size > 0) {
                signature.append (@"extends $(this.get_implementations_str(interfaces))");
            }

            signature.append ("{\n");


            // Overloaded Signals
            var overloaded_ts_signals = this.get_missing_overloaded_signals ();
            if (overloaded_ts_signals.size > 0) {
                signature.append_line ("// Overloaded Signals\n");
                foreach (var ts_signal in overloaded_ts_signals.values) {
                    signature.append_content (ts_signal.build_signature_for_interface ());
                    signature.append ("\n",false);
                }
            }

            // Overload Methods
            var overloaded_ts_methods = this.get_missing_overloaded_methods ();
            if (overloaded_ts_methods.size > 0) {
                signature.append_line ("// Overloaded Methods\n");
                foreach (var ts_method in overloaded_ts_methods.values) {
                    signature.append_content (ts_method.build_signature ());
                    signature.append ("\n",false);
                }
            }

            signature.append_line (@"}\n");
        }
        return signature.to_string ();
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

        signature.append_line (this.build_inheritance_interface_signature ());

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

        signature.append (this.get_type_parameter_signature (),false);

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
            signature.append (@"implements $(this.get_implementations_str(interfaces))");
        }

        // START Body
        signature.append_content ("{\n");

        //
        // Properties
        //
        var properties = this._class.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY },false);
        signature.append_line ("// Properties\n");
        foreach (var prop in properties) {
            var ts_prop = new Typescript.Property (this.root_namespace,prop as Valadoc.Api.Property,this);
            signature.append_content (ts_prop.get_signature ());
            signature.append (";\n",false);
        }

        //
        // Constructors
        //
        var ts_constructors = this.get_creation_methods ();
        if (ts_constructors.size > 0) {
            signature.append_line ("// Constructors\n");
            // Default constructor TODO add parameters
            signature.append_line ("public constructor ()\n");
            foreach (var ts_constructor in ts_constructors.values) {
                signature.append_content (ts_constructor.get_signature ());
                signature.append (";\n", false);
            }
            //
            // Overloaded Constructors
            //
            var overloaded_ts_creation_methods = this.get_missing_overloaded_creation_methods ();
            if (overloaded_ts_creation_methods.size > 0) {
                signature.append_line ("// Overloaded Constructors\n");
                foreach (var ts_creation_method in overloaded_ts_creation_methods.values) {
                    signature.append_content (ts_creation_method.get_signature ());
                    signature.append ("\n", false);
                }
            }
        }

        //
        // Static Methods
        //
        var ts_static_methods = this.get_static_methods ();
        signature.append_line ("// Static Methods\n");
        foreach (var ts_method in ts_static_methods.values) {
            signature.append_content (ts_method.get_signature ());
            signature.append (";\n", false);
        }

        //
        // Methods
        //
        var ts_methods = this.get_methods ();
        signature.append_line ("// Methods\n");
        foreach (var ts_method in ts_methods.values) {
            signature.append_content (ts_method.get_signature ());
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
        var ts_signals = this.get_signals ();
        if (ts_signals.size > 0) {
            signature.append_line ("// Signals\n");
            foreach (var ts_signal in ts_signals.values) {
                signature.append_content (ts_signal.get_signature ());
                signature.append ("\n", false);
            }
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}