
/**
 * <TypeParameter1, TypeParameter2>
 */
public class Typescript.TypeParameter : Typescript.Signable {
    protected Valadoc.Api.TypeParameter type_param;

    public TypeParameter (Valadoc.Api.TypeParameter type_param) {
        this.type_param = type_param;
    }

    /**
     * Basesd on libvaladoc/api/typeparameter.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_symbol (this.type_param);
        return signature.to_string ();
    }
}