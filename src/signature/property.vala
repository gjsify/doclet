public class Typescript.Property : Typescript.Signable {
    protected Valadoc.Api.Property prop;

    public Property (Valadoc.Api.Property prop) {
        this.prop = prop;
    }

    /**
     * Basesd on libvaladoc/api/property.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this.prop.accessibility.to_string ());
        if (this.prop.is_abstract) {
            signature.append_keyword ("abstract");
        } else if (this.prop.is_override) {
            signature.append_keyword ("override");
        } else if (this.prop.is_virtual) {
            signature.append_keyword ("virtual");
        }

        // Write only
        if (this.prop.getter == null && this.prop.setter != null) {
            signature.append ("readonly");
        }

        // Read only
        if (this.prop.getter != null && this.prop.setter == null) {
            // TODO setter?
        }


        signature.append_symbol (this.prop);

        signature.append (":", false);

        var type = this.prop.property_type;
        var ts_type = new Typescript.TypeReference (type);
        signature.append_content (ts_type.get_signature (root_namespace) /*this.prop.property_type.signature*/);

        signature.append (";", false);


        return signature.to_string ();
    }
}