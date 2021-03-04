public class Typescript.Delegate : Typescript.Signable {
    protected Valadoc.Api.Delegate deleg;

    public Delegate (Valadoc.Api.Delegate deleg) {
        this.deleg = deleg;
    }

    /**
     * Basesd on libvaladoc/api/delegate.vala
     */
    protected override string build_signature () {

        this.signature.append_keyword (this.deleg.accessibility.to_string ());
        this.signature.append_keyword ("delegate");

        var ts_data_type = new Typescript.TypeReference (this.deleg.return_type);
        this.signature.append_content (ts_data_type.get_signature ());
        this.signature.append_symbol (this.deleg);

        var type_parameters = this.deleg.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            this.signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (!first) {
                    this.signature.append (",", false);
                }
                var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
                this.signature.append_content (ts_param.get_signature (), false);
                first = false;
            }
            this.signature.append (">", false);
        }

        this.signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this.deleg.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                this.signature.append (",", false);
            }
            var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
            this.signature.append_content (ts_param.get_signature (), !first);
            first = false;
        }

        this.signature.append (")", false);

        var exceptions = this.deleg.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS });
        if (exceptions.size > 0) {
            this.signature.append_keyword ("throws");
            first = true;
            foreach (Valadoc.Api.Node param in exceptions) {
                if (!first) {
                    this.signature.append (",", false);
                }
                this.signature.append_type (param);
                first = false;
            }
        }

        return this.signature.to_string ();
    }
}