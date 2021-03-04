public class Typescript.Constant : Typescript.Signable {
    protected Valadoc.Api.Constant cons;

    public Constant (Valadoc.Api.Constant cons) {
        this.cons = cons;
    }

    /**
     * Basesd on libvaladoc/api/Constant.vala
     */
	protected override string build_signature () {
		if (this.cons.get_full_name() == null) {
			return "";
		}
		var ts_constant_type = new Typescript.TypeReference(this.cons.constant_type as Valadoc.Api.TypeReference);
		this.signature.append_keyword ("const");

		this.signature.append_keyword (this.cons.accessibility.to_string ());
		this.signature.append (this.cons.get_full_name());
		this.signature.append (": ", false);
		this.signature.append_content (ts_constant_type.get_signature());

		return this.signature.to_string();
	}

}