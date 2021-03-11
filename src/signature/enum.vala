public class Typescript.Enum : Typescript.Signable {
    protected Valadoc.Api.Enum _enum;

    public Enum (Typescript.Namespace ? root_namespace, Valadoc.Api.Enum _enum) {
        this.root_namespace = root_namespace;
        this._enum = _enum;
    }

    public Gee.HashMap<string, Typescript.EnumValue> get_values () {
        var values = this._enum.get_children_by_types ({ Valadoc.Api.NodeType.ENUM_VALUE }, false);
        var ts_values = new Gee.HashMap<string, Typescript.EnumValue> ();
        foreach (var val in values) {
            var ts_val = new Typescript.EnumValue (this.root_namespace, val as Valadoc.Api.EnumValue);
            ts_values.set (ts_val.get_name (), ts_val);
        }
        return ts_values;
    }

    public override string get_name () {
        var result = "";
        if (this.root_namespace != null) {
            result = root_namespace.remove_vala_namespace (this._enum.get_full_name ());
        } else {
            result = this._enum.get_full_name ();
        }


        return result;
    }

    /**
     * Remove the Class name from a function name
     */
    public string remove_namespace (string vala_full_name) {
        return Typescript.remove_namespace (vala_full_name, this.get_name ());
    }

    public string build_values_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var ts_enum_values = this.get_values ();

        foreach (var ts_enum in ts_enum_values.values) {
            signature.append_content (ts_enum.get_signature ());
            signature.append (",\n", false);
        }
        return signature.to_string ();
    }

    /**
     * Basesd on libvaladoc/api/enum.vala
     */
    protected override string build_signature () {
        if (this._enum.get_full_name () == null) {
            return "";
        }
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._enum.accessibility.to_string (); // private || public || protected
        return signature
                .append_keyword ("export")
                .append ("/*")
                .append_keyword (accessibility)
                .append ("*/")
                .append_keyword ("enum")
                .append (this.get_name ())
                .append ("{\n")
                .append (this.build_values_signature ())
                .append_line ("}")
                .to_string ();
    }
}