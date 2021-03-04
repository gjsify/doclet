public class Typescript.Field : Typescript.Signable {
    protected Valadoc.Api.Field field;

    public Field (Valadoc.Api.Field field) {
        this.field = field;
    }

    /**
     * Basesd on libvaladoc/api/field.vala
     */
	 protected override string build_signature () {
		this.signature.append_keyword (this.field.accessibility.to_string ());
		if (this.field.is_static) {
			this.signature.append_keyword ("static");
		} else if (this.field.is_class) {
			this.signature.append_keyword ("class");
		}
		if (this.field.is_volatile) {
			this.signature.append_keyword ("volatile");
		}
		var ts_field_type = new Typescript.TypeReference(this.field.field_type as Valadoc.Api.TypeReference);
		this.signature.append_content (ts_field_type.get_signature());
		this.signature.append_symbol (this.field);
		return this.signature.get ();
	}

}