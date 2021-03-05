public class Typescript.Dependency : Typescript.Signable {
    protected Valadoc.Api.Package package;

    public Dependency (Valadoc.Api.Package package) {
        this.package = package;
    }

    /**
     * Basesd on libvaladoc/api/packageeter.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append (@"import type * as $(this.package.name) from './GLib-2.0'");
        return signature.to_string ();
    }
}