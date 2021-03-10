public class Typescript.Struct : Typescript.Signable {
    protected Valadoc.Api.Struct _struct;

    public Struct (Typescript.Namespace ? root_namespace, Valadoc.Api.Struct struc) {
        this.root_namespace = root_namespace;
        this._struct = struc;
    }

    public Vala.ArrayList<Typescript.Field> get_fields (Typescript.Namespace ? root_namespace) {
        var fields = this._struct.get_children_by_types ({ Valadoc.Api.NodeType.FIELD }, false);
        Vala.ArrayList<Typescript.Field> ts_fields = new Vala.ArrayList<Typescript.Field> ();
        foreach (var field in fields) {
            var ts_field = new Typescript.Field (this.root_namespace, field as Valadoc.Api.Field);
            ts_fields.add (ts_field);
        }
        return ts_fields;
    }

    public Vala.ArrayList<Typescript.Method> get_methods () {
        var methods = this._struct.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        Vala.ArrayList<Typescript.Method> ts_methods = new Vala.ArrayList<Typescript.Method> ();
        foreach (var method in methods) {
            var ts_method = new Typescript.Method (this.root_namespace, method as Valadoc.Api.Method, null, null, this, null, null);
            ts_methods.add (ts_method);
        }
        return ts_methods;
    }

    public string build_fields_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var ts_struct_fields = this.get_fields (root_namespace);

        foreach (var ts_field in ts_struct_fields) {
            signature.append_content (ts_field.get_signature ());
            signature.append (";\n", false);
        }
        // Records, classes and interfaces all have a static name
        signature.append ("static name: string;\n", false);
        return signature.to_string ();
    }

    public string build_methods_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var ts_methods = this.get_methods ();

        foreach (var ts_method in ts_methods) {
            signature.append_content (ts_method.get_signature ());
            signature.append (";\n", false);
        }
        return signature.to_string ();
    }

    public string get_name () {
        var name = this._struct.get_full_name ();
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

    /**
     * Basesd on libvaladoc/api/struct.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._struct.accessibility.to_string ();

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" * @struct as interface\n", false);
        signature.append (" */\n", false);

        if (accessibility == "public") {
            signature.append ("export");
        }


        signature.append_keyword ("interface");
        signature.append (this.get_name ());

        var type_parameters = this._struct.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (!first) {
                    signature.append (",", false);
                }
                var ts_param = new Typescript.TypeParameter (this.root_namespace, param as Valadoc.Api.TypeParameter);
                signature.append_content (ts_param.get_signature (), false);
                first = false;
            }
            signature.append (">", false);
        }


        if (this._struct.base_type != null) {
            signature.append ("extends");

            var ts_base_type = new Typescript.TypeReference (this.root_namespace, this._struct.base_type as Valadoc.Api.TypeReference);
            signature.append_content (ts_base_type.get_signature ());
        }

        signature.append ("{\n")
         .append (this.build_fields_signature ())
         .append (this.build_methods_signature ())
         .append ("\n}");

        return signature.to_string ();
    }
}