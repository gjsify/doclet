public class Typescript.Delegate : Typescript.Signable {
    protected Valadoc.Api.Delegate deleg;

    public Delegate (Valadoc.Api.Delegate deleg) {
        this.deleg = deleg;
    }

    /**
     * Basesd on libvaladoc/api/delegate.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();

        signature.append_keyword (this.deleg.accessibility.to_string ());
        signature.append_keyword ("delegate");

        var ts_data_type = new Typescript.TypeReference (this.deleg.return_type);
        signature.append_content (ts_data_type.get_signature (root_namespace));
        signature.append_symbol (this.deleg);

        var type_parameters = this.deleg.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (!first) {
                    signature.append (",", false);
                }
                var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
                signature.append_content (ts_param.get_signature (root_namespace), false);
                first = false;
            }
            signature.append (">", false);
        }

        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this.deleg.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
            signature.append_content (ts_param.get_signature (root_namespace), !first);
            first = false;
        }

        signature.append (")", false);

        var exceptions = this.deleg.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
        if (exceptions.size > 0) {
            signature.append_keyword ("throws");
            first = true;
            foreach (Valadoc.Api.Node param in exceptions) {
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_type (param);
                first = false;
            }
        }

        return signature.to_string ();
    }
}