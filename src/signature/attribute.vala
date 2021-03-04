public class Typescript.Attribute : Typescript.Signable {
    protected Valadoc.Api.Attribute attr;

    public Attribute (Valadoc.Api.Attribute attr) {
        this.attr = attr;
    }

    /**
     * Basesd on libvaladoc/api/attribute.vala
     */
    protected override string build_signature () {

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
            return this.signature.to_string ();
        }

        this.signature.append_attribute ("[");
        this.signature.append_type_name (attr.name);

        if (keys.get_length () > 0) {
            this.signature.append_attribute ("(");

            unowned string separator = "";
            var arg_iter = keys.get_begin_iter ();
            while (!arg_iter.is_end ()) {
                unowned string arg_name = arg_iter.get ();
                arg_iter = arg_iter.next ();
                if (separator != "") {
                    this.signature.append_attribute (", ");
                }
                if (arg_name != "cheader_filename") {
                    this.signature.append_attribute (arg_name);
                    this.signature.append_attribute ("=");
                    this.signature.append_literal (attr.args.get (arg_name));
                }
                separator = ", ";
            }

            this.signature.append_attribute (")");
        }
        this.signature.append_attribute ("]");

        return this.signature.to_string ();
    }
}