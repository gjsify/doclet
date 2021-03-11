public class Typescript.Constant : Typescript.Signable {
    protected Valadoc.Api.Constant _constant;

    public Constant (Typescript.Namespace ? root_namespace, Valadoc.Api.Constant _constant) {
        this.root_namespace = root_namespace;
        this._constant = _constant;
    }

    /**
     * Get full name for typescript for currrent root namespace.
     * Reverts the namespace conversion of vala
     */
    public override string get_name () {
        var vala_full_name = this._constant.get_full_name ();
        var result = vala_full_name;
        if (this.root_namespace != null) {
            result = root_namespace.remove_vala_namespace (vala_full_name);
        }
        result = result.replace (".", "_").up ();
        result = result.replace ("@", "");
        return result;
    }

    /**
     * Basesd on libvaladoc/api/Constant.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        if (this._constant.get_full_name () == null) {
            return "/* error on constant */";
        }
        var ts_constant_type = new Typescript.TypeReference (this.root_namespace, this._constant.constant_type as Valadoc.Api.TypeReference);
        signature.append ("export");
        signature.append_keyword ("const");
        signature.append ("/*");
        signature.append_keyword (this._constant.accessibility.to_string ());
        signature.append ("*/");
        signature.append (this.get_name ());
        signature.append (": ", false);
        signature.append (ts_constant_type.get_signature ());
        signature.append (";", false);

        return signature.to_string ();
    }
}