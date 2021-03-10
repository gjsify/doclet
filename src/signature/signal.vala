public class Typescript.Signal : Typescript.Signable {
    protected Valadoc.Api.Signal _signal;
    protected Typescript.Class _class;

    public Signal (Typescript.Namespace ? root_namespace, Valadoc.Api.Signal sig, Typescript.Class cl) {
        this.root_namespace = root_namespace;
        this._signal = sig;
        this._class = cl;
    }

    public string get_signal_methods () {
        var signature = new Typescript.SignatureBuilder ();
        var name = this._signal.name;
        var cl = this._class.get_name ();
        var parameters = this.get_parameters ();
        var return_type = this.get_return_type ();
        var accessibility = this._signal.accessibility.to_string ();
        var keyword = "";
        if (this._signal.is_virtual) {
            keyword = "abstract ";
        }
        signature.append_line (@"$(accessibility) $(keyword) connect(sigName: \"$(name)\", callback: ((obj: $(cl), $(parameters)) => $(return_type) )): number;");
        signature.append_line (@"$(accessibility) $(keyword) connect_after(sigName: \"$(name)\", callback: ((obj: $(cl), $(parameters)) => $(return_type) )): number;");
        signature.append_line (@"$(accessibility) $(keyword) emit(sigName: \"$(name)\", $(parameters)): void;");
        return signature.to_string ();
    }

    public string get_parameters () {
        var signature = new Typescript.SignatureBuilder ();
        bool first = true;
        foreach (Valadoc.Api.Node param in this._signal.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (this.root_namespace, param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (), !first);
            first = false;
        }
        return signature.to_string ();
    }

    public string get_return_type () {
        var ts_return_type = new Typescript.TypeReference (this.root_namespace, this._signal.return_type as Valadoc.Api.TypeReference);
        return ts_return_type.get_signature ();
    }

    /**
     * Based on libvaladoc/api/signal.vala
     */
    protected string build_vala_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this._signal.accessibility.to_string ());
        if (this._signal.is_virtual) {
            signature.append_keyword ("virtual");
        }

        signature.append_keyword ("signal");

        var ts_return_type = new Typescript.TypeReference (this.root_namespace, this._signal.return_type as Valadoc.Api.TypeReference);
        signature.append_content (ts_return_type.get_signature ());
        signature.append_symbol (this._signal);
        signature.append ("(");

        bool first = true;
        foreach (Valadoc.Api.Node param in this._signal.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
            if (!first) {
                signature.append (",", false);
            }
            var ts_param = new Typescript.Parameter (this.root_namespace, param as Valadoc.Api.Parameter);
            signature.append_content (ts_param.get_signature (), !first);
            first = false;
        }

        signature.append (")", false);

        return signature.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/signal.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var vala_signatur = "// " + this.build_vala_signature ();
        signature.append_line (vala_signatur);

        signature.append_line (this.get_signal_methods ());

        return signature.to_string ();
    }
}