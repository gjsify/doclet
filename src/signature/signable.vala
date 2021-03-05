public abstract class Typescript.Signable {
    protected Vala.HashMap<string, string> signatures = new Vala.HashMap<string, string> ();

    public string get_signature (Typescript.Namespace ? root_namespace) {
        string ns = "";
        if (root_namespace != null && root_namespace is Typescript.Namespace) {
            ns = root_namespace.get_signature (null);
        }
        var old_sig = signatures.get (ns);
        if (old_sig != null) {
            return old_sig.to_string ();
        }
        var new_sig = this.build_signature (root_namespace);
        signatures.set (ns, new_sig);
        return new_sig.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/array.vala
     */
    public abstract string build_signature (Typescript.Namespace ? root_namespace);
}