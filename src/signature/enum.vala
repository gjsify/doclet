public class Typescript.Enum : Typescript.Signable {
    protected Valadoc.Api.Enum _enum;

    public Enum (Valadoc.Api.Enum _enum) {
        this._enum = _enum;
    }

    /**
     * Basesd on libvaladoc/api/enum.vala
     */
	 protected override string build_signature () {
		if (this._enum.get_full_name() == null) {
			return "";
		}
		return this.signature
		.append_keyword (this._enum.accessibility.to_string ())
		.append_keyword ("enum")
		.append (this._enum.get_full_name())
		.to_string();
	}

}