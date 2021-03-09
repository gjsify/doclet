public class Typescript.Delegate : Typescript.Signable {
    protected Valadoc.Api.Delegate deleg;

    public Delegate (Valadoc.Api.Delegate deleg) {
        this.deleg = deleg;
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        return this.deleg.name;
    }

    public string get_return_type (Typescript.Namespace ? root_namespace) {
        var ts_data_type = new Typescript.TypeReference (this.deleg.return_type);
        var return_type = ts_data_type.get_signature (root_namespace);
        return return_type;
    }

    /**
     * Basesd on libvaladoc/api/delegate.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this.deleg.accessibility.to_string ();

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" * @delegate as interface\n", false);
        signature.append (" */\n", false);

        if (accessibility == "public") {
            signature.append ("export");
        }

        signature.append ("interface");

        signature.append (this.get_name (root_namespace));

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

        signature.append ("{\n");

        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this.deleg.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (root_namespace), !first);
            first = false;
        }

        signature.append (")");
        signature.append (":");
        signature.append (this.get_return_type (root_namespace));

        var exceptions = this.deleg.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
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
        signature.append (";");

        signature.append ("\n}");



        return signature.to_string ();
    }
}