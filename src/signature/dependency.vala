public class Typescript.Dependency : Typescript.Signable {
    protected Valadoc.Api.Package package;

    public Dependency (Valadoc.Api.Package package) {
        this.package = package;
    }

    /**
     * Basesd on libvaladoc/api/packageeter.vala
     */
	protected override string build_signature () {
		this.signature.append(@"import type * as $(this.package.name) from './GLib-2.0'");
		return this.signature.to_string();
	}

}