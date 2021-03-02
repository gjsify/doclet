public class Typescript.Property {
    protected Valadoc.Api.Property prop;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Property (Valadoc.Api.Property prop) {
        this.prop = prop;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/property.vala
     */
	 protected string build_signature () {
		this.signature.append_keyword (this.prop.accessibility.to_string ());
		if (this.prop.is_abstract) {
			this.signature.append_keyword ("abstract");
		} else if (this.prop.is_override) {
			this.signature.append_keyword ("override");
		} else if (this.prop.is_virtual) {
			this.signature.append_keyword ("virtual");
		}

		// Write only
		if (this.prop.getter == null && this.prop.setter != null) {
			this.signature.append ("readonly");
		}

		// Read only
		if (this.prop.getter != null && this.prop.setter == null) {
			// TODO setter?
		}


		this.signature.append_symbol (this.prop);

		this.signature.append (":", false);

		var type = this.prop.property_type;
		var ts_type = new Typescript.TypeReference(type); 
		this.signature.append_content (ts_type.get_signature() /*this.prop.property_type.signature*/);

		this.signature.append (";", false);


		return this.signature.to_string();
	}

}