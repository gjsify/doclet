public class Typescript.Attribute {
    protected Valadoc.Api.Attribute attr;
    protected Typescript.SignatureBuilder builder = new Typescript.SignatureBuilder ();

    public Attribute (Valadoc.Api.Attribute attr) {
        this.attr = attr;
    }

    public string get_signature () {
        if (this.builder.to_string ().length <= 0) {
            return build_signature ();
        } else {
            return this.builder.to_string ();
        }
    }

    /**
     * Basesd on libvaladoc/api/attribute.vala
     */
    protected string build_signature () {


        unowned Vala.Attribute attr = (Vala.Attribute) this.attr.data;

        var keys = new GLib.Sequence<string> ();
        foreach (var key in attr.args.get_keys ()) {
            if (key == "cheader_filename") {
                continue;
            }
            keys.insert_sorted (key, (CompareDataFunc<string>)strcmp);
        }

        if (attr.name == "CCode" && keys.get_length () == 0) {
            // only cheader_filename on namespace
            return this.builder.to_string ();
        }

        this.builder.append_attribute ("[");
        this.builder.append_type_name (attr.name);

        if (keys.get_length () > 0) {
            this.builder.append_attribute ("(");

            unowned string separator = "";
            var arg_iter = keys.get_begin_iter ();
            while (!arg_iter.is_end ()) {
                unowned string arg_name = arg_iter.get ();
                arg_iter = arg_iter.next ();
                if (separator != "") {
                    this.builder.append_attribute (", ");
                }
                if (arg_name != "cheader_filename") {
                    this.builder.append_attribute (arg_name);
                    this.builder.append_attribute ("=");
                    this.builder.append_literal (attr.args.get (arg_name));
                }
                separator = ", ";
            }

            this.builder.append_attribute (")");
        }
        this.builder.append_attribute ("]");

        return this.builder.to_string ();
    }
}