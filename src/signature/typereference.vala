public class Typescript.TypeReference : Typescript.Signable {
    protected Valadoc.Api.TypeReference type_ref;

    public TypeReference (Valadoc.Api.TypeReference type_ref) {
        this.type_ref = type_ref;
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

        // Type
        string ? type = null;
        if (this.type_ref.data_type == null) {
            type = "void";
        } else if (this.type_ref.data_type is Valadoc.Api.Symbol) {
            var symbol = this.type_ref.data_type as Valadoc.Api.Symbol;
            type = symbol.get_full_name ();
            // type = (this.type_ref.data.to_string()); // => Gtk.Widget
        } else if (this.type_ref.data_type is Valadoc.Api.TypeReference) {
            var ts_data_type = new Typescript.TypeReference (this.type_ref.data_type as Valadoc.Api.TypeReference);
            type = ts_data_type.get_signature (root_namespace);
        }

        if (type == null) {
            type = "any";
        }
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