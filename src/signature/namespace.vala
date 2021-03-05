public class Typescript.Namespace : Typescript.Signable {
    public Valadoc.Api.Namespace vala_namespace;
    public string vala;

    public Namespace (Valadoc.Api.Namespace vala_namespace) {
        this.vala_namespace = vala_namespace;
        this.vala = this.vala_namespace.data.to_string();
    }

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
	protected override string build_signature () {
		this.signature.append (this.vala_namespace.data.to_string(), false);
		return this.signature.to_string();
	}

}