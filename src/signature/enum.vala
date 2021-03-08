public class Typescript.Enum : Typescript.Signable {
    protected Valadoc.Api.Enum _enum;

    public Enum (Valadoc.Api.Enum _enum) {
        this._enum = _enum;
    }

    public Vala.ArrayList<Typescript.EnumValue> get_values(Typescript.Namespace ? root_namespace) {
        var values = this._enum.get_children_by_types ({ Valadoc.Api.NodeType.ENUM_VALUE },false);
        Vala.ArrayList<Typescript.EnumValue> ts_values = new Vala.ArrayList<Typescript.EnumValue> ();
        foreach (var val in values) {
            var ts_val = new Typescript.EnumValue (val as Valadoc.Api.EnumValue);
            ts_values.add(ts_val);
        }
        return ts_values;
    }

    public string build_values_signature(Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var ts_enum_values = this.get_values(root_namespace);
        
        foreach (var ts_enum in ts_enum_values) {
            signature.append_content (ts_enum.get_signature (root_namespace));
            signature.append (",\n",false);
        }
        return signature.to_string();
    }


    /**
     * Basesd on libvaladoc/api/enum.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        if (this._enum.get_full_name () == null) {
            return "";
        }
        var signature = new Typescript.SignatureBuilder ();
        return signature
            .append_keyword ("export")
            .append ("/*")
            .append_keyword (this._enum.accessibility.to_string ())
            .append ("*/")
            .append_keyword ("enum")
            .append (root_namespace.remove_vala_namespace(this._enum.get_full_name ()))
            .append ("{\n")
            .append(this.build_values_signature(root_namespace))
            .append_line ("}")
            .to_string();
    }
}