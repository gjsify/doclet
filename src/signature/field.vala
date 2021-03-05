public class Typescript.Field : Typescript.Signable {
    protected Valadoc.Api.Field field;

    public Field (Valadoc.Api.Field field) {
        this.field = field;
    }

    /**
     * Basesd on libvaladoc/api/field.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this.field.accessibility.to_string ());
        if (this.field.is_static) {
            signature.append_keyword ("static");
        } else if (this.field.is_class) {
            signature.append_keyword ("class");
        }
        if (this.field.is_volatile) {
            signature.append_keyword ("volatile");
        }
        var ts_field_type = new Typescript.TypeReference (this.field.field_type as Valadoc.Api.TypeReference);
        signature.append_content (ts_field_type.get_signature (root_namespace));
        signature.append_symbol (this.field);
        return signature.get ();
    }
}