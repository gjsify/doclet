public class Typescript.Array : Typescript.Signable {
    protected Valadoc.Api.Array array;

    public Array (Typescript.Namespace ? root_namespace, Valadoc.Api.Array array) {
        this.root_namespace = root_namespace;
        this.array = array;
    }

    private inline bool element_is_owned () {
        Valadoc.Api.TypeReference reference = this.array.data_type as Valadoc.Api.TypeReference;
        if (reference == null) {
            return true;
        }

        return !reference.is_unowned && !reference.is_weak;
    }

    /**
     * Basesd on libvaladoc/api/array.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var ts_data_type = new Typescript.TypeReference (this.root_namespace, this.array.data_type as Valadoc.Api.TypeReference);
        if (this.element_is_owned ()) {
            signature.append_content (ts_data_type.get_signature ());
        } else {
            signature.append ("(", false);
            signature.append_content (ts_data_type.get_signature (), false);
            signature.append (")", false);
        }
        signature.append ("[]", false);
        return signature.to_string ();
    }
}