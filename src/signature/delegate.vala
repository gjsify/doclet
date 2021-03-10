public class Typescript.Delegate : Typescript.Signable {
    protected Valadoc.Api.Delegate _delegate;

    public Delegate (Typescript.Namespace ? root_namespace, Valadoc.Api.Delegate _delegate) {
        this.root_namespace = root_namespace;
        this._delegate = _delegate;
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        return this._delegate.name;
    }

    public string get_return_type () {
        var ts_data_type = new Typescript.TypeReference (this.root_namespace, this._delegate.return_type);
        var return_type = ts_data_type.get_signature ();
        return return_type;
    }

    /**
     * Basesd on libvaladoc/api/delegate.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._delegate.accessibility.to_string ();

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

        var type_parameters = this._delegate.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

        signature.append ("{\n");

        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this._delegate.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (this.root_namespace, param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (), !first);
            first = false;
        }

        signature.append (")");
        signature.append (":");
        signature.append (this.get_return_type ());

        var exceptions = this._delegate.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
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