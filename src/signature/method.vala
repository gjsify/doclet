public class Typescript.Method : Typescript.Signable {
    /**
     * Original method object of Valadoc
     */
    protected Valadoc.Api.Method _method;
    /**
     * Parent Class of this method
     */
    protected Typescript.Class ? _class = null;
    /**
     * Parent Interface of this method
     */
    protected Typescript.Interface ? _interface = null;
    /**
     * Parent Struct of this method
     */
    protected Typescript.Struct ? _struct = null;
    /**
     * Parent Enum of this method
     */
    protected Typescript.Enum ? _enum = null;
    /**
     * Parent Error Domain of this method
     * In Vala Error Domains can have methods
     */
    protected Typescript.ErrorDomain ? _error_domain = null;

    public Method (Valadoc.Api.Method m, Typescript.Class ? cls, Typescript.Interface ? iface, Typescript.Struct ? stru, Typescript.Enum ? enu, Typescript.ErrorDomain ? error_domain) {
        this._method = m;
        this._class = cls;
        this._interface = iface;
        this._struct = stru;
        this._enum = enu;
        this._error_domain = error_domain;
    }

    public bool is_global (Typescript.Namespace ? root_namesp) {
        var name = this.get_name (root_namesp);
        if (Typescript.has_parent_namespace (name)) {
            return false;
        }
        return this._class == null && this._interface == null && this._struct == null && this._enum == null && this._error_domain == null;
    }

    public string get_name (Typescript.Namespace ? root_namespace, bool as_virtual = false) {
        var name = this._method.get_full_name ();
        bool has_vala_at_prefix = false;
        name = root_namespace.remove_vala_namespace (name);
        // Remove class name if present
        if (this._class != null) {
            name = this._class.remove_namespace (root_namespace, name);
        }
        // Remove interface name if present
        if (this._interface != null) {
            name = this._interface.remove_namespace (root_namespace, name);
        }
        if (name.has_prefix ("@")) {
            has_vala_at_prefix = true;
            name = name.substring (1);
        }

        if (this._method.is_constructor) {
            var parent_name = this.get_parent_name (root_namespace);
            if (parent_name != null) {
                if (name == parent_name) {
                    name = "new";
                } else {
                    var prefix = parent_name + ".";
                    if (name.has_prefix (prefix)) {

                        name = "new_" + name.substring (prefix.length);
                    }
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

    /**
     * Name of the class or interface in which this method is defined
     */
    public string ? get_parent_name (Typescript.Namespace ? root_namespace) {
        if (this._interface != null) {
            return this._interface.get_name (root_namespace);
        }
        if (this._class != null) {
            return this._class.get_name (root_namespace);
        }
        if (this._struct != null) {
            return this._struct.get_name (root_namespace);
        }
        if (this._enum != null) {
            return this._enum.get_name (root_namespace);
        }
        return null;
    }

    public string ? get_parent_type () {
        if (this._interface != null) {
            return "interface";
        }
        if (this._class != null) {
            return "class";
        }
        if (this._struct != null) {
            return "struct";
        }
        if (this._enum != null) {
            return "enum";
        }
        if (this._error_domain != null) {
            return "errordomain";
        }
        return "unknown";
    }

    public string get_return_type (Typescript.Namespace ? root_namespace) {
        if (this._method.is_constructor) {
            var parent = this.get_parent_name (root_namespace);
            if (parent != null) {
                return parent;
            } else {
                GLib.stderr.printf (@"Parent for constructor of $(this.get_parent_type()) \"$(this.get_name(root_namespace))\" not found!\n");
            }
        }
        var ts_return_type = new Typescript.TypeReference (this._method.return_type as Valadoc.Api.TypeReference);
        var result = ts_return_type.get_signature (root_namespace);
        return result;
    }

    /**
     * Basesd on libvaladoc/api/method.vala
     */
    protected string ? _build_signature (Typescript.Namespace ? root_namespace, bool as_virtual) {
        if (as_virtual && (!this._method.is_abstract && !this._method.is_virtual)) {
            return null;
        }

        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._method.accessibility.to_string ();



        if (this.is_global (root_namespace)) {
            if (accessibility == "public") {
                signature.append_keyword ("export function");
            }
        } else {
            signature.append_keyword (this._method.accessibility.to_string ());
        }

        if (!this._method.is_constructor) {
            if (this._method.is_static) {
                signature.append_keyword ("static");
            } else if (this._method.is_class) {
                signature.append_keyword ("/* class */");
            } else if (this._method.is_abstract) {
                signature.append_keyword ("abstract");
            } else if (this._method.is_override) {
                signature.append_keyword ("/* override */");
            } else if (this._method.is_virtual) {
                signature.append_keyword ("/* virtual */");
            }
            if (this._method.is_inline) {
                signature.append_keyword ("/* inline */");
            }
        }

        if (this._method.is_yields) {
            signature.append_keyword ("async");
        }

        signature.append (this.get_name (root_namespace, as_virtual));

        var type_parameters = this._method.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_content (ts_param.get_signature (root_namespace), false);
                first = false;
            }
            signature.append (">", false);
        }

        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this._method.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            var ts_param = new Typescript.Parameter (param as Valadoc.Api.Parameter);
            if (!first) {
                signature.append (",", false);
            }
            signature.append_content (ts_param.get_signature (root_namespace), !first);
            first = false;
        }

        signature.append (")", false);

        //
        // Return type
        //
        signature.append (":", false);
        signature.append_content (this.get_return_type (root_namespace));

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

        signature.append (";", false);

        return signature.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/method.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var normal = this._build_signature (root_namespace, false);
        if (normal != null) {
            signature.append_line (normal);
        }

        var virtual = this._build_signature (root_namespace, true);
        if (virtual != null) {
            signature.append_line (virtual);
        }
        return signature.to_string ();
    }
}