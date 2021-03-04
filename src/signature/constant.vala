public class Typescript.Constant {
    protected Valadoc.Api.Constant cons;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Constant (Valadoc.Api.Constant cons) {
        this.cons = cons;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/Constant.vala
     */
	 protected string build_signature () {
		var ts_constant_type = new Typescript.TypeReference(this.cons.constant_type as Valadoc.Api.TypeReference);
		this.signature.append_keyword (this.cons.accessibility.to_string ())
		.append_keyword ("const")
		.append_content (ts_constant_type.get_signature())
		.append_symbol (this.cons);

		return this.signature.to_string();
	}

}