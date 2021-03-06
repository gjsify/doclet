public class Typescript.Method : Typescript.Signable {
    protected Valadoc.Api.Method m;

    public Method (Valadoc.Api.Method m) {
        this.m = m;
    }

    public string get_name (bool as_virtual = false) {
        var name = this.m.name;
        if (name.has_prefix ("@")) {
            name = "/* @ */ " + name.substring (1);
        }
        if (as_virtual && (this.m.is_abstract || this.m.is_virtual)) {
            name = "vfunc_" + name;
        }
        return name;
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
                signature.append_keyword ("class");
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

        signature.append (this.get_name (as_virtual));

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
        if (!this.m.is_constructor) {
            signature.append (":", false);
            var ts_return_type = new Typescript.TypeReference (this.m.return_type as Valadoc.Api.TypeReference);
            signature.append_content (ts_return_type.get_signature (root_namespace));
        }

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