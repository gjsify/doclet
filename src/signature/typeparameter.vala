
/**
 * <TypeParameter1, TypeParameter2>
 */
public class Typescript.TypeParameter {
    protected Valadoc.Api.TypeParameter type_param;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public TypeParameter (Valadoc.Api.TypeParameter type_param) {
        this.type_param = type_param;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/typeparameter.vala
     */
	 protected string build_signature () {
		this.signature.append_symbol (this.type_param);
		return this.signature.to_string();
	}

}