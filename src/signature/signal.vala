public class Typescript.Signal : Typescript.Signable {
    protected Valadoc.Api.Signal _signal;
    protected Typescript.Class _class;

    public Signal (Typescript.Namespace ? root_namespace, Valadoc.Api.Signal _signal, Typescript.Class _class) {
        this.root_namespace = root_namespace;
        this._signal = _signal;
        this._class = _class;
    }

    public string get_name () {
        return this._signal.name;
    }

    public string get_signal_methods () {
        var signature = new Typescript.SignatureBuilder ();
        var name = this.get_name ();
        var cl = this._class.get_name ();
        var parameters = this.get_parameters ();
        var return_type = this.get_return_type ();
        var accessibility = this._signal.accessibility.to_string ();
        var keyword = "";
        if (this._signal.is_virtual && this._class.is_abstract ()) {
            keyword = "/* abstract */";
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
     * Basesd on libvaladoc/api/signal.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var vala_signatur = "// " + this.get_name ();
        signature.append_line (vala_signatur);

        signature.append_line (this.get_signal_methods ());

        return signature.to_string ();
    }
}