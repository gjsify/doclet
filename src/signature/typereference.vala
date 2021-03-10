public class Typescript.TypeReference : Typescript.Signable {
    protected Valadoc.Api.TypeReference type_ref;

    public TypeReference (Valadoc.Api.TypeReference type_ref) {
        this.type_ref = type_ref;
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        string ? type = null;
        if (this.type_ref.data_type == null) {
            type = "void";
        } else if (this.type_ref.data_type is Valadoc.Api.Symbol) {
            var symbol = this.type_ref.data_type as Valadoc.Api.Symbol;
            type = this.get_name_from_symbol (root_namespace, symbol);
            // type = (this.type_ref.data.to_string()); // => Gtk.Widget
        } else if (this.type_ref.data_type is Valadoc.Api.TypeReference) {
            var ts_data_type = new Typescript.TypeReference (this.type_ref.data_type as Valadoc.Api.TypeReference);
            type = ts_data_type.get_signature (root_namespace);
        }

        if (type == null) {
            type = "any";
        }
        type = Typescript.transform_type (type);
        return type;
    }

    protected string get_name_from_symbol (Typescript.Namespace ? root_namespace, Valadoc.Api.Symbol symbol) {
        if (symbol is Valadoc.Api.Class) {
            var ts_symbol = new Typescript.Class (symbol as Valadoc.Api.Class);
            return ts_symbol.get_name (root_namespace);
        }
        if (symbol is Valadoc.Api.Interface) {
            var ts_symbol = new Typescript.Interface (symbol as Valadoc.Api.Interface);
            return ts_symbol.get_name (root_namespace);
        }
        if (symbol is Valadoc.Api.Struct) {
            var ts_symbol = new Typescript.Struct (symbol as Valadoc.Api.Struct);
            return ts_symbol.get_name (root_namespace);
        }
        if (symbol is Valadoc.Api.Enum) {
            var ts_symbol = new Typescript.Enum (symbol as Valadoc.Api.Enum);
            return ts_symbol.get_name (root_namespace);
        }
        var type_full_name = symbol.get_full_name ();
        return root_namespace.remove_vala_namespace (type_full_name);
    }

    /**
     * Basesd on libvaladoc/api/typereference.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        if (this.type_ref.is_dynamic) {
            signature.append_keyword ("/* dynamic */");
        }

        if (this.type_ref.is_weak) {
            signature.append_keyword ("/* weak */");
        } else if (this.type_ref.is_owned) {
            signature.append_keyword ("/* owned */");
        } else if (this.type_ref.is_unowned) {
            signature.append_keyword ("/* unowned */");
        }

        if (this.type_ref.data_type is Valadoc.Api.Symbol) {
            var valadoc_type = this.type_ref.data_type.get_type ().name ();
            signature.append (@"/* $(valadoc_type) */");
        }

        // Type
        var type = this.get_name (root_namespace);
        signature.append (type);

        var type_arguments = this.type_ref.get_type_arguments ();
        if (type_arguments.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item type_arg in type_arguments) {
                var ts_type_arg = new TypeReference (type_arg as Valadoc.Api.TypeReference);
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_content (ts_type_arg.build_signature (root_namespace), false);
                first = false;
            }
            signature.append (">", false);
        }

        if (this.type_ref.is_nullable) {
            signature.append ("?", false);
        }
        return signature.to_string ();
    }
}