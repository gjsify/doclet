public class Typescript.Namespace : Typescript.Signable {
    public Valadoc.Api.Namespace vala_namespace;
    public Typescript.Package package;
    public string vala;

    public Namespace (Valadoc.Api.Namespace vala_namespace, Typescript.Package package) {
        this.package = package;
        this.vala_namespace = vala_namespace;
        this.vala = this.vala_namespace.data.to_string ();
        if (this.is_root ()) {
            print (@"$(this.get_vala_namespace_name()): $(this.get_gir_namespace_name())\n");
        }
    }

    public override string get_name () {
        return this.get_gir_namespace_name ();
    }

    public string get_vala_namespace_name () {
        return this.vala_namespace.name;
    }

    public string get_gir_namespace_name () {
        return this.package.get_gir_namespace ();
    }

    public string remove_vala_namespace (string vala_full_name) {
        return Typescript.remove_namespace (vala_full_name, this.get_vala_namespace_name ());
    }

    public bool is_root () {
        var ns_str = this.get_signature ();
        var result = ns_str.index_of_char ('.') <= -1;
        return result;
    }

    /**
     * Basesd on libvaladoc/api/Namespace.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append (this.get_vala_namespace_name (), false);
        return signature.to_string ();
    }
}