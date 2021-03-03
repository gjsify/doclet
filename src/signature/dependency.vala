public class Typescript.Dependency {
    protected Valadoc.Api.Package package;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Dependency (Valadoc.Api.Package package) {
        this.package = package;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}


    /**
     * Basesd on libvaladoc/api/packageeter.vala
     */
	protected string build_signature () {
		this.signature.append(@"import type * as $(this.package.name) from './GLib-2.0'");
		return this.signature.to_string();
	}

}