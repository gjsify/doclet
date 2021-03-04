public class Typescript.Namespace {
    public Valadoc.Api.Namespace nspace;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Namespace (Valadoc.Api.Namespace nspace) {
        this.nspace = nspace;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
	protected string build_signature () {
		this.signature.append (this.nspace.data.to_string(), false);
		return this.signature.to_string();
	}

}