public class Typescript.Array : Typescript.Signable {
    protected Valadoc.Api.Array array;

    public Array (Valadoc.Api.Array array) {
        this.array = array;
    }

	private inline bool element_is_owned () {
		Valadoc.Api.TypeReference reference = this.array.data_type as Valadoc.Api.TypeReference;
		if (reference == null) {
			return true;
		}

		return !reference.is_unowned && !reference.is_weak;
	}

    /**
     * Basesd on libvaladoc/api/array.vala
     */
	protected override string build_signature () {
		var ts_data_type = new Typescript.TypeReference(this.array.data_type as Valadoc.Api.TypeReference);
		if (this.element_is_owned ()) {
			this.signature.append_content (ts_data_type.get_signature());
		} else {
			this.signature.append ("(", false);
			this.signature.append_content (ts_data_type.get_signature(), false);
			this.signature.append (")", false);
		}
		this.signature.append ("[]", false);
		return this.signature.to_string();
	}

}