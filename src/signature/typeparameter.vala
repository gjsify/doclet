
/**
 * <TypeParameter1, TypeParameter2>
 */
public class Typescript.TypeParameter : Typescript.Signable {
    protected Valadoc.Api.TypeParameter type_param;

    public TypeParameter (Typescript.Namespace ? root_namespace, Valadoc.Api.TypeParameter type_param) {
        this.root_namespace = root_namespace;
        this.type_param = type_param;
    }

    public override string get_name () {
        var name = this.type_param.name;
        name = Typescript.transform_type (name);
        return name;
    }

    /**
     * Basesd on libvaladoc/api/typeparameter.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append (this.get_name ());
        return signature.to_string ();
    }
}