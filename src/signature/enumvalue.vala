public class Typescript.EnumValue : Typescript.Signable {
    protected Valadoc.Api.EnumValue _enum_value;

    public EnumValue (Typescript.Namespace ? root_namespace, Valadoc.Api.EnumValue enum_value) {
        this.root_namespace = root_namespace;
        this._enum_value = enum_value;
    }

    public string get_default_value () {
        var default_value = this._enum_value.default_value;
        return default_value.style.to_string () + " TODO";
    }

    /**
     * Basesd on libvaladoc/api/enumvalue.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_symbol (this._enum_value);

        if (this._enum_value.has_default_value) {
            signature.append ("=");

            signature.append_content (this.get_default_value ());
        }

        return signature.to_string ();
    }
}