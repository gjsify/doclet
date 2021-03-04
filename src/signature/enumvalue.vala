public class Typescript.EnumValue : Typescript.Signable {
    protected Valadoc.Api.EnumValue e_val;

    public EnumValue (Valadoc.Api.EnumValue e_val) {
        this.e_val = e_val;
    }

	public string get_default_value() {
		var default_value = this.e_val.default_value;
		return default_value.style.to_string() + " TODO";
	}

    /**
     * Basesd on libvaladoc/api/enumvalue.vala
     */
	 protected override string build_signature () {
		this.signature.append_symbol (this.e_val);

		if (e_val.has_default_value) {
			this.signature.append ("=");

			this.signature.append_content (this.get_default_value());
		}

		return this.signature.to_string();
	}

}