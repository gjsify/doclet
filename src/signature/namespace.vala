public class Typescript.Namespace : Typescript.Signable {
    public Valadoc.Api.Namespace vala_namespace;
    public string vala;

    public Namespace (Valadoc.Api.Namespace vala_namespace) {
        this.vala_namespace = vala_namespace;
        this.vala = this.vala_namespace.data.to_string ();
    }

    public bool is_root () {
        var ns_str = this.get_signature (null);
        return ns_str.index_of_char ('.') <= -1;
    }

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append (this.vala_namespace.data.to_string (), false);
        return signature.to_string ();
    }
}