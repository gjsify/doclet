public class Typescript.Method : Typescript.Signable {
    /**
     * Original method object of Valadoc
     */
    protected Valadoc.Api.Method _method;
    /**
     * Parent Class / Interface / Struct / Enum Error Domain of this method
     */
    protected Typescript.Signable ? parent_symbol = null;

    public Method (Typescript.Namespace ? root_namespace, Valadoc.Api.Method _method, Typescript.Signable ? parent_symbol) {
        this.root_namespace = root_namespace;
        this._method = _method;
        this.parent_symbol = parent_symbol;
    }

    public bool is_global () {
        var name = this.get_name ();
        if (this.root_namespace != null && Typescript.has_parent_namespace (name)) {
            return false;
        }
        return this.parent_symbol == null;
    }

    protected string _get_name (bool as_virtual = false) {
        var name = this._method.get_full_name ();
        bool has_vala_at_prefix = false;
        // Remove root namespace if present
        if (this.root_namespace != null) {
            name = this.root_namespace.remove_vala_namespace (name);
        }
        // Remove class name if present
        if (this.parent_symbol != null) {
            if (this.parent_symbol is Typescript.Class) {
                var _class = this.parent_symbol as Typescript.Class;
                name = _class.remove_namespace (name);
            }
            // Remove interface name if present
            if (this.parent_symbol is Typescript.Interface) {
                var _iface = this.parent_symbol as Typescript.Interface;
                name = _iface.remove_namespace (name);
            }
            // Remove interface name if present
            if (this.parent_symbol is Typescript.Enum) {
                var _enum = this.parent_symbol as Typescript.Enum;
                name = _enum.remove_namespace (name);
            }
        }
        if (name.has_prefix ("@")) {
            has_vala_at_prefix = true;
            name = name.substring (1);
        }

        var parent_name = this.get_parent_name ();
        if (parent_name != null && parent_name.has_prefix (Typescript.RESERVED_RENAME_PREFIX)) {
            parent_name = parent_name.substring (1);
        }
        if (this._method.is_constructor) {
            if (parent_name != null) {
                if (name == parent_name) {
                    name = "new" + this.get_type_parameter_signature ();
                } else {
                    var prefix = parent_name + ".";
                    if (name.has_prefix (prefix)) {
                        name = name.substring (prefix.length);
                        name = "new_" + name + this.get_type_parameter_signature ();
                    }
                }
            }
        } else {
            if (parent_name != null) {
                var prefix = parent_name + ".";
                if (name.has_prefix (prefix)) {
                    name = name.substring (prefix.length);
                }
                if (name.has_prefix ("@")) {
                    has_vala_at_prefix = true;
                    name = name.substring (1);
                }
            }
        }
        if (as_virtual && (this._method.is_abstract || this._method.is_virtual)) {
            name = "vfunc_" + name;
        }

        if (has_vala_at_prefix) {
            name = "/* @ */ " + name;
        }

        return name;
    }

    public override string get_name () {
        return this._get_name ();
    }

    public string get_type_parameter_signature () {
        if (this.parent_symbol != null) {
            if (this.parent_symbol is Typescript.Class) {
                var _class = this.parent_symbol as Typescript.Class;
                return _class.get_type_parameter_signature ();
            }
        }
        return "";
    }

    public string ? get_parent_type_signature () {
        if (this.parent_symbol != null) {
            if (this.parent_symbol is Typescript.Class) {
                var _class = this.parent_symbol as Typescript.Class;
                return _class.get_name () + _class.get_type_parameter_signature ();
            }
            return this.parent_symbol.get_name ();
        }
        return null;
    }

    /**
     * Name of the class or interface in which this method is defined
     */
    public string ? get_parent_name () {

        if (this.parent_symbol != null) {
            return this.parent_symbol.get_name ();
        }

        return null;
    }

    public string ? get_parent_type () {
        if (this.parent_symbol != null) {
            if (this.parent_symbol is Typescript.Interface) {
                return "interface";
            }
            if (this.parent_symbol is Typescript.Class) {
                return "class";
            }
            if (this.parent_symbol is Typescript.Struct) {
                return "struct";
            }
            if (this.parent_symbol is Typescript.Enum) {
                return "enum";
            }
            if (this.parent_symbol is Typescript.ErrorDomain) {
                return "errordomain";
            }
        }

        return "unknown";
    }

    public string get_return_type () {
        string ? result = null;
        if (this._method.is_constructor) {
            result = this.get_parent_type_signature ();
            if (result != null) {
                return result;
            } else {
                GLib.stderr.printf (@"Parent for constructor of '$(this.get_parent_type())' '$(this.get_name())' not found!\n");
            }
        }
        var ts_return_type = new Typescript.TypeReference (this.root_namespace, this._method.return_type as Valadoc.Api.TypeReference);
        result = ts_return_type.get_signature ();
        return result;
    }

    public string get_accessibility () {
        return this._method.accessibility.to_string ();
    }

    public bool is_public () {
        return this.get_accessibility () == "public";
    }

    /**
     * Basesd on libvaladoc/api/method.vala
     */
    protected string ? _build_signature (bool as_virtual) {
        if (as_virtual && (!this._method.is_abstract && !this._method.is_virtual)) {
            return null;
        }

        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._method.accessibility.to_string ();



        if (this.is_global ()) {
            if (accessibility == "public") {
                signature.append_keyword ("export function");
            }
        } else {
            if (this.get_parent_type () == "class") {
                // Public is the default
                if (accessibility != "public") {
                    signature.append_keyword (accessibility);
                }
            } else {
                signature.append_keyword (@"/* $(accessibility)*/");
            }
        }

        if (!this._method.is_constructor) {
            if (this._method.is_static) {
                signature.append_keyword ("static");
            } else if (this._method.is_class) {
                signature.append_keyword ("/* class */");
            } else if (this._method.is_abstract) {
                signature.append_keyword ("/* abstract */");
            } else if (this._method.is_override) {
                signature.append_keyword ("/* override */");
            } else if (this._method.is_virtual) {
                signature.append_keyword ("/* virtual */");
            }
            if (this._method.is_inline) {
                signature.append_keyword ("/* inline */");
            }
        } else {
            signature.append_keyword ("static");
        }

        if (this._method.is_yields) {
            signature.append_keyword ("async");
        }

        signature.append (this._get_name (as_virtual));

        var type_parameters = this._method.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this._method.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            var ts_param = new Typescript.Parameter (this.root_namespace, param as Valadoc.Api.Parameter);
            if (!first) {
                signature.append (",", false);
            }
            signature.append_content (ts_param.get_signature (), !first);
            first = false;
        }

        signature.append (")", false);

        //
        // Return type
        //
        signature.append (":", false);
        signature.append_content (this.get_return_type ());

        var exceptions = this._method.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
        if (exceptions.size > 0) {
            signature.append ("/*");
            signature.append_keyword ("throws");
            first = true;
            foreach (Valadoc.Api.Node param in exceptions) {
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_type (param);
                first = false;
            }
            signature.append ("*/");
        }

        // signature.append (";", false);

        return signature.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/method.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var normal = this._build_signature (false);
        if (normal != null) {
            signature.append_line (normal);
        }

        var virtual = this._build_signature (true);
        if (virtual != null) {
            signature.append_line (virtual);
        }
        return signature.to_string ();
    }
}