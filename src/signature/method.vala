public class Typescript.Method : Typescript.Signable {
    protected Valadoc.Api.Method m;
    protected Typescript.Class? cls = null;
    protected Typescript.Interface? iface = null;

    public Method (Valadoc.Api.Method m, Typescript.Class? cls, Typescript.Interface? iface) {
        this.m = m;
        this.cls = cls;
        this.iface = iface;
    }

    public string get_name (Typescript.Namespace ? root_namespace, bool as_virtual = false) {
        var name = this.m.get_full_name();
        name = root_namespace.remove_vala_namespace(name);
        // Remove class name if present
        if (this.cls != null) {
            name = this.cls.remove_namespace(name);
        }
        // Remove interface name if present
        if (this.iface != null) {
            name = this.iface.remove_namespace(name);
        }
        if (name.has_prefix ("@")) {
            name = "/* @ */ " + name.substring (1);
        }

        if (this.m.is_constructor) {
            var parent_name = this.get_parent_name(root_namespace);
            if (parent_name != null) {
                if (name == parent_name) {
                    name = "new";
                } else  {
                    var prefix = parent_name + ".";
                    if (name.has_prefix(prefix)) {
                        
                        name = "new_" + name.substring(prefix.length);
                    }
                }
            }
        }
        if (as_virtual && (this.m.is_abstract || this.m.is_virtual)) {
            name = "vfunc_" + name;
        }
        return name;
    }

    /**
     * Name of the class or interface in which this method is defined
     */
    public string? get_parent_name (Typescript.Namespace ? root_namespace) {
        if(this.iface != null) {
            return this.iface.get_name();
        }
        if(this.cls != null) {
            return this.cls.get_name();
        }
        return null;
    }

    public string get_return_type(Typescript.Namespace ? root_namespace) {
        if (this.m.is_constructor) {
            return this.get_parent_name(root_namespace);
        }
        var ts_return_type = new Typescript.TypeReference (this.m.return_type as Valadoc.Api.TypeReference);
        var result = ts_return_type.get_signature (root_namespace);
        return result;
    }

    /**
     * Basesd on libvaladoc/api/method.vala
     */
    protected string ? _build_signature (Typescript.Namespace ? root_namespace, bool as_virtual) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this.m.accessibility.to_string ());

        if (as_virtual && (!this.m.is_abstract && !this.m.is_virtual)) {
            return null;
        }

        if (!this.m.is_constructor) {
            if (this.m.is_static) {
                signature.append_keyword ("static");
            } else if (this.m.is_class) {
                signature.append_keyword ("/* class */");
            } else if (this.m.is_abstract) {
                signature.append_keyword ("abstract");
            } else if (this.m.is_override) {
                signature.append_keyword ("/* override */");
            } else if (this.m.is_virtual) {
                signature.append_keyword ("/* virtual */");
            }
            if (this.m.is_inline) {
                signature.append_keyword ("/* inline */");
            }
        }

        if (this.m.is_yields) {
            signature.append_keyword ("async");
        }

        signature.append (this.get_name (root_namespace, as_virtual));

        var type_parameters = this.m.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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
        foreach (Valadoc.Api.Node param in this.m.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
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
        signature.append_content (this.get_return_type(root_namespace));

        var exceptions = this.m.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
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