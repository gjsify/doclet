public class Typescript.ErrorCode {
    protected Valadoc.Api.ErrorCode error_code;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public ErrorCode (Valadoc.Api.ErrorCode error_code) {
        this.error_code = error_code;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/errorcode.vala
     */
	 protected string build_signature () {
		return this.signature
		.append_symbol (error_code)
		.to_string();
	}

}