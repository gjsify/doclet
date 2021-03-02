public class Typescript.Parameter {
    protected Valadoc.Api.Parameter param;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Parameter (Valadoc.Api.Parameter param) {
        this.param = param;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}


    /**
     * Basesd on libvaladoc/api/parameter.vala
     */
	protected string build_signature () {
		if (this.param.ellipsis) {
			this.signature.append ("...");
		} else {
			if (this.param.is_out) {
				this.signature.append_keyword ("out");
			} else if (this.param.is_ref) {
				this.signature.append_keyword ("ref");
			}


			var type = this.param.parameter_type;
			var ts_type = new Typescript.TypeReference(type); 
			this.signature.append_content (ts_type.get_signature());
			this.signature.append (this.param.name);

			if (this.param.has_default_value) {
				this.signature.append ("=");
				this.signature.append_content (@"TODO default_value" /* this.param.default_value */);
			}
		}

		return this.signature.to_string();
	}

}