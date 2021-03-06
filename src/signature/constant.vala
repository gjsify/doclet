public class Typescript.Constant : Typescript.Signable {
    protected Valadoc.Api.Constant cons;

    public Constant (Valadoc.Api.Constant cons) {
        this.cons = cons;
    }

    /**
     * Get full name for typescript for currrent root namespace.
     * Reverts the namespace conversion of vala
     */
    protected string get_full_name (Typescript.Namespace ? root_namespace) {
        if (root_namespace == null) {
            return this.cons.get_full_name ();
        }
        var vala_full_name = this.cons.get_full_name ();
        var name_without_root = root_namespace.remove_vala_namespace (vala_full_name);
        var result = name_without_root.replace (".", "_").up ();
        return result;
    }

    /**
     * Basesd on libvaladoc/api/Constant.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        if (this.cons.get_full_name () == null) {
            return "";
        }
        var ts_constant_type = new Typescript.TypeReference (this.cons.constant_type as Valadoc.Api.TypeReference);
        signature.append_keyword ("const");

        signature.append_keyword (this.cons.accessibility.to_string ());
        signature.append (this.get_full_name (root_namespace));
        signature.append (": ", false);
        signature.append (ts_constant_type.get_signature (root_namespace));
        signature.append (";", false);

        return signature.to_string ();
    }
}