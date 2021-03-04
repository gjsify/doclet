public class Typescript.Enum {
    protected Valadoc.Api.Enum _enum;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Enum (Valadoc.Api.Enum _enum) {
        this._enum = _enum;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/enum.vala
     */
	 protected string build_signature () {
		return this.signature
		.append_keyword (this._enum.accessibility.to_string ())
		.append_keyword ("enum")
		.append_symbol (this._enum)
		.to_string();
	}

}