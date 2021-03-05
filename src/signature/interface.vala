public class Typescript.Interface : Typescript.Signable {
    protected Valadoc.Api.Interface iface;

    public Interface (Valadoc.Api.Interface iface) {
        this.iface = iface;
    }

    public string get_name () {
        return this.iface.name;
    }

    /**
     * Basesd on libvaladoc/api/interface.vala
     */
    public override string build_signature (Typescript.Namespace ? root_namespace) {
        print ("build_signature");
        var signature = new Typescript.SignatureBuilder ();
        print ("accessibility");
        var accessibility = this.iface.accessibility.to_string (); // "public" or "private"

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" */\n", false);

        signature.append ("export");
        // signature.append_keyword ("abstract class");
        signature.append_keyword ("interface");
        signature.append_symbol (this.iface);

        print ("type_parameters");

        var type_parameters = this.iface.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (param is Valadoc.Api.TypeParameter) {
                    var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
                    print ("param " + ts_param.get_signature (root_namespace));
                    if (!first) {
                        signature.append (",", false);
                    }
                    signature.append_content (ts_param.get_signature (root_namespace), false);
                    first = false;
                }
            }
            signature.append (">", false);
        }

        //
        // Extended class
        //
        bool first = true;
        if (this.iface.base_type != null && this.iface.base_type is Valadoc.Api.TypeReference) {
            signature.append ("extends");

            var base_type = (Valadoc.Api.TypeReference) this.iface.base_type;
            var ts_base_type = new Typescript.TypeReference (base_type);

            signature.append_content (ts_base_type.get_signature (root_namespace));
            first = false;
        }

        //
        // Extended interfaces
        //
        var interfaces = this.iface.get_implemented_interface_list ();
        if (interfaces.size > 0) {
            if (first) {
                signature.append ("extends");
            }

            foreach (Valadoc.Api.Item _implemented_interface in interfaces) {
                if (!first) {
                    signature.append (",", false);
                }
                var implemented_interface = (Valadoc.Api.TypeReference)_implemented_interface;
                var ts_implemented_interface = new Typescript.TypeReference (implemented_interface);
                signature.append_content (ts_implemented_interface.get_signature (root_namespace));
                first = false;
            }
        }

        // START Body
        signature.append_content ("{\n");

        //
        // Properties
        //
        var properties = iface.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        foreach (var _prop in properties) {
            var prop = (Valadoc.Api.Property)_prop;
            var ts_prop = new Typescript.Property (prop);
            signature.append_content (ts_prop.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Methods
        //
        var methods = iface.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var _m in methods) {
            var m = (Valadoc.Api.Method)_m;
            var ts_m = new Typescript.Method (m);
            signature.append_content (ts_m.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}