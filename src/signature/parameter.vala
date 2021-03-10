public class Typescript.Parameter : Typescript.Signable {
    protected Valadoc.Api.Parameter param;

    public Parameter (Typescript.Namespace ? root_namespace, Valadoc.Api.Parameter param) {
        this.root_namespace = root_namespace;
        this.param = param;
    }

    public string get_name () {
        var name = this.param.name;
        if (name.has_prefix ("@")) {
            name = name.substring (1);
        }
        if (Typescript.is_reserved_variable_name (name)) {
            return Typescript.RESERVED_RENAME_PREFIX + name;
        }
        return name;
    }

    /**
     * Basesd on libvaladoc/api/parameter.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        if (this.param.ellipsis) {
            signature.append ("...args: any[]");
        } else {
            if (this.param.is_out) {
                signature.append_keyword ("/* out */");
            } else if (this.param.is_ref) {
                signature.append_keyword ("/* ref */");
            }

            signature.append (this.get_name ());
            signature.append (":");

            var type = this.param.parameter_type;
            var ts_type = new Typescript.TypeReference (this.root_namespace, type);
            signature.append_content (ts_type.get_signature ());


            if (this.param.has_default_value) {
                signature.append ("/*");
                signature.append ("=");
                signature.append_content ("default_value" /* this.param.default_value */);
                signature.append ("*/");
            }
        }

        return signature.to_string ();
    }
}