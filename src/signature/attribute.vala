public class Typescript.Attribute : Typescript.Signable {
    protected Valadoc.Api.Attribute attr;

    public Attribute (Valadoc.Api.Attribute attr) {
        this.attr = attr;
    }

    /**
     * Basesd on libvaladoc/api/attribute.vala
     */
	protected override string build_signature (Typescript.Namespace? root_namespace) {
        var signature = new Typescript.SignatureBuilder();

        var attr = (Vala.Attribute) this.attr.data;

        var keys = new GLib.Sequence<string> ();
        foreach (var key in attr.args.get_keys ()) {
            if (key == "cheader_filename") {
                continue;
            }
            keys.insert_sorted (key, (CompareDataFunc<string>)strcmp);
        }

        if (attr.name == "CCode" && keys.get_length () == 0) {
            // only cheader_filename on namespace
            return signature.to_string ();
        }

        signature.append_attribute ("[");
        signature.append_type_name (attr.name);

        if (keys.get_length () > 0) {
            signature.append_attribute ("(");

            unowned string separator = "";
            var arg_iter = keys.get_begin_iter ();
            while (!arg_iter.is_end ()) {
                unowned string arg_name = arg_iter.get ();
                arg_iter = arg_iter.next ();
                if (separator != "") {
                    signature.append_attribute (", ");
                }
                if (arg_name != "cheader_filename") {
                    signature.append_attribute (arg_name);
                    signature.append_attribute ("=");
                    signature.append_literal (attr.args.get (arg_name));
                }
                separator = ", ";
            }

            signature.append_attribute (")");
        }
        signature.append_attribute ("]");

        return signature.to_string ();
    }
}