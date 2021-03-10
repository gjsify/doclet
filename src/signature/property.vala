public class Typescript.Property : Typescript.Signable {
    protected Valadoc.Api.Property prop;

    public Property (Typescript.Namespace ? root_namespace, Valadoc.Api.Property prop) {
        this.root_namespace = root_namespace;
        this.prop = prop;
    }

    /**
     * Basesd on libvaladoc/api/property.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_keyword (this.prop.accessibility.to_string ());
        if (this.prop.is_abstract) {
            signature.append_keyword ("abstract");
        } else if (this.prop.is_override) {
            signature.append_keyword ("override");
        } else if (this.prop.is_virtual) {
            signature.append_keyword ("/* virtual */");
        }

        // Write only
        if (this.prop.getter == null && this.prop.setter != null) {
            // TODO setter?
        }

        // Read only
        if (this.prop.getter != null && this.prop.setter == null) {
            signature.append ("readonly");
        }


        signature.append_symbol (this.prop);

        signature.append (":", false);

        var type = this.prop.property_type;
        var ts_type = new Typescript.TypeReference (this.root_namespace, type);
        signature.append_content (ts_type.get_signature () /*this.prop.property_type.signature*/);

        // signature.append (";", false);


        return signature.to_string ();
    }
}