public abstract class Typescript.Signable {
    protected Vala.HashMap<string, string> signatures = new Vala.HashMap<string, string> ();
    protected Typescript.Namespace ? root_namespace = null;

    public abstract string get_name ();

    public string get_signature () {
        string ns = "";
        if (this.root_namespace != null && this.root_namespace is Typescript.Namespace) {
            ns = this.root_namespace.get_signature ();
        }
        var old_sig = signatures.get (ns);
        if (old_sig != null) {
            return old_sig.to_string ();
        }
        var new_sig = this.build_signature ();
        signatures.set (ns, new_sig);
        return new_sig.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/array.vala
     */
    public abstract string build_signature ();
}