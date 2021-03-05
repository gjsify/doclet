public class Typescript.ErrorCode : Typescript.Signable {
    protected Valadoc.Api.ErrorCode error_code;

    public ErrorCode (Valadoc.Api.ErrorCode error_code) {
        this.error_code = error_code;
    }

    /**
     * Basesd on libvaladoc/api/errorcode.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        return signature
                .append_symbol (error_code)
                .to_string ();
    }
}