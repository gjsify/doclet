public class Typescript.Namespace : Typescript.Signable {
    public Valadoc.Api.Namespace vala_namespace;
    public Typescript.Package package;
    public string vala;

    public Namespace (Valadoc.Api.Namespace vala_namespace, Typescript.Package package) {
        this.package = package;
        this.vala_namespace = vala_namespace;
        this.vala = this.vala_namespace.data.to_string ();
    }

    public string get_vala_namespace_name () {
        return this.vala_namespace.name;
    }

    public string get_gir_namespace_name () {
        return this.package.get_gir_namespace ();
    }

    public string remove_vala_namespace (string vala_full_name) {
        var root_prefix = this.get_vala_namespace_name () + ".";
        string result;
        if (vala_full_name.has_prefix (root_prefix)) {
            print ("\n true");
            result = vala_full_name.substring (root_prefix.length);
        } else {
            result = vala_full_name;
        }
        return result;
    }

    public bool is_root () {
        var ns_str = this.get_signature (null);
        var result = ns_str.index_of_char ('.') <= -1;
        // print ("\n is_root" + (result == true ? "true" : "false"));
        return result;
    }

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append (this.get_vala_namespace_name (), false);
        return signature.to_string ();
    }
}