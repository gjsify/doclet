public class Typescript.Parameter : Typescript.Signable {
    protected Valadoc.Api.Parameter param;

    public Parameter (Valadoc.Api.Parameter param) {
        this.param = param;
    }

    /**
     * Basesd on libvaladoc/api/parameter.vala
     */
	protected override string build_signature () {
		if (this.param.ellipsis) {
			this.signature.append ("...args: any[]");
		} else {
			if (this.param.is_out) {
				this.signature.append_keyword ("/* out */");
			} else if (this.param.is_ref) {
				this.signature.append_keyword ("/* ref */");
			}

			this.signature.append (this.param.name);
			this.signature.append (":");

			var type = this.param.parameter_type;
			var ts_type = new Typescript.TypeReference(type);
			this.signature.append_content (ts_type.get_signature());
			

			if (this.param.has_default_value) {
				this.signature.append ("/*");
				this.signature.append ("=");
				this.signature.append_content ("default_value" /* this.param.default_value */);
				this.signature.append ("*/");
			}
		}

		return this.signature.to_string();
	}

}