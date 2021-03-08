public class Typescript.Struct : Typescript.Signable {
    protected Valadoc.Api.Struct _struct;

    public Struct (Valadoc.Api.Struct struc) {
        this._struct = struc;
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        return this._struct.name;
    }

    /**
     * Basesd on libvaladoc/api/struct.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature
         .append_keyword (this._struct.accessibility.to_string ());
        signature.append_keyword ("struct");
        signature.append (this.get_name (root_namespace));

        var type_parameters = this._struct.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (!first) {
                    signature.append (",", false);
                }
                var ts_param = new Typescript.Parameter (param as Valadoc.Api.Parameter);
                signature.append_content (ts_param.get_signature (root_namespace), false);
                first = false;
            }
            signature.append (">", false);
        }

        if (this._struct.base_type != null) {
            signature.append (":");

            var ts_base_type = new Typescript.TypeReference (this._struct.base_type as Valadoc.Api.TypeReference);
            signature.append_content (ts_base_type.get_signature (root_namespace));
        }

        return signature.to_string ();
    }
}