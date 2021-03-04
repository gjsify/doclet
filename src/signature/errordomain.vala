public class Typescript.ErrorDomain {
    protected Valadoc.Api.ErrorDomain error_domain;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public ErrorDomain (Valadoc.Api.ErrorDomain error_domain) {
        this.error_domain = error_domain;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/errordomain.vala
     */
	 protected string build_signature () {
		return this.signature.append_keyword (this.error_domain.accessibility.to_string ())
		.append_keyword ("errordomain")
		.append_symbol (this.error_domain)
		.to_string ();
	}

}