public class Typescript.ErrorDomain : Typescript.Signable {
    protected Valadoc.Api.ErrorDomain error_domain;

    public ErrorDomain (Valadoc.Api.ErrorDomain error_domain) {
        this.error_domain = error_domain;
    }

    /**
     * Basesd on libvaladoc/api/errordomain.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        return signature.append_keyword (this.error_domain.accessibility.to_string ())
                .append_keyword ("errordomain")
                .append_symbol (this.error_domain)
                .to_string ();
    }
}