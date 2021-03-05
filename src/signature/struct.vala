public class Typescript.Struct : Typescript.Signable {
    protected Valadoc.Api.Struct struc;

    public Struct (Valadoc.Api.Struct struc) {
        this.struc = struc;
    }

    /**
     * Basesd on libvaladoc/api/struct.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature
         .append_keyword (this.struc.accessibility.to_string ());
        signature.append_keyword ("struct");
        signature.append_symbol (this.struc);

        var type_parameters = this.struc.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

        if (this.struc.base_type != null) {
            signature.append (":");

            var ts_base_type = new Typescript.TypeReference (this.struc.base_type as Valadoc.Api.TypeReference);
            signature.append_content (ts_base_type.get_signature (root_namespace));
        }

        return signature.to_string ();
    }
}