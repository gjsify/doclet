public class Typescript.Signal : Typescript.Signable {
    protected Valadoc.Api.Signal sig;
    protected Typescript.Class cl;

    public Signal (Valadoc.Api.Signal sig, Typescript.Class cl) {
        this.sig = sig;
        this.cl = cl;
    }

    public string get_signal_methods (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var name = this.sig.name;
        var cl = this.cl.get_name ();
        var parameters = this.get_parameters (root_namespace);
        var return_type = this.get_return_type (root_namespace);
        var accessibility = this.sig.accessibility.to_string ();
        var keyword = "";
        if (this.sig.is_virtual) {
            keyword = "abstract ";
        }
        signature.append_line (@"$(accessibility) $(keyword) connect(sigName: \"$(name)\", callback: ((obj: $(cl), $(parameters)) => $(return_type) )): number;");
        signature.append_line (@"$(accessibility) $(keyword) connect_after(sigName: \"$(name)\", callback: ((obj: $(cl), $(parameters)) => $(return_type) )): number;");
        signature.append_line (@"$(accessibility) $(keyword) emit(sigName: \"$(name)\", $(parameters)): void;");
        return signature.to_string ();
    }

    public string get_parameters (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        bool first = true;
        foreach (Valadoc.Api.Node param in this.sig.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (root_namespace), !first);
            first = false;
        }
        return signature.to_string ();
    }

    public string get_return_type (Typescript.Namespace ? root_namespace) {
        var ts_return_type = new Typescript.TypeReference (this.sig.return_type as Valadoc.Api.TypeReference);
        return ts_return_type.get_signature (root_namespace);
    }

    /**
     * Based on libvaladoc/api/signal.vala
     */
    protected string build_vala_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this.sig.accessibility.to_string ());
        if (this.sig.is_virtual) {
            signature.append_keyword ("virtual");
        }

        signature.append_keyword ("signal");

        var ts_return_type = new Typescript.TypeReference (this.sig.return_type as Valadoc.Api.TypeReference);
        signature.append_content (ts_return_type.get_signature (root_namespace));
        signature.append_symbol (this.sig);
        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this.sig.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (root_namespace), !first);
            first = false;
        }

        signature.append (")", false);

        return signature.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/signal.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var vala_signatur = "// " + this.build_vala_signature (root_namespace);
        signature.append_line (vala_signatur);

        signature.append_line (this.get_signal_methods (root_namespace));

        return signature.to_string ();
    }
}