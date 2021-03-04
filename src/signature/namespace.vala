public class Typescript.Namespace : Typescript.Signable {
    public Valadoc.Api.Namespace nspace;

    public Namespace (Valadoc.Api.Namespace nspace) {
        this.nspace = nspace;
    }

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
	protected override string build_signature () {
		this.signature.append (this.nspace.data.to_string(), false);
		return this.signature.to_string();
	}

}