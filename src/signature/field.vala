public class Typescript.Field : Typescript.Signable {
    protected Valadoc.Api.Field field;

    public Field (Typescript.Namespace ? root_namespace, Valadoc.Api.Field field) {
        this.root_namespace = root_namespace;
        this.field = field;
    }

    public override string get_name () {
        return this.field.name;
    }

    /**
     * Basesd on libvaladoc/api/field.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();

        var accessibility = this.field.accessibility.to_string ();
        if (accessibility != "public") {
            printerr (@"WARN: Struct field $(this.get_name()) is not public!\n");
            return "";
        }
        if (this.field.is_static) {
            signature.append_keyword ("static");
        } else if (this.field.is_class) {
            signature.append_keyword ("class");
        }
        if (this.field.is_volatile) {
            signature.append_keyword ("volatile");
        }

        signature.append (this.get_name ());
        signature.append (":");

        var ts_field_type = new Typescript.TypeReference (this.root_namespace, this.field.field_type as Valadoc.Api.TypeReference);
        signature.append_content (ts_field_type.get_signature ());

        return signature.to_string ();
    }
}