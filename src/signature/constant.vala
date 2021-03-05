public class Typescript.Constant : Typescript.Signable {
    protected Valadoc.Api.Constant cons;

    public Constant (Valadoc.Api.Constant cons) {
        this.cons = cons;
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
        signature.append (this.cons.get_full_name ());
        signature.append (": ", false);
        signature.append_content (ts_constant_type.get_signature (root_namespace));

        return signature.to_string ();
    }
}