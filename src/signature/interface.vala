public class Typescript.Interface : Typescript.Signable {
    protected Valadoc.Api.Interface _interface;

    public Interface (Valadoc.Api.Interface iface) {
        this._interface = iface;
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        var name = this._interface.get_full_name ();
        if (root_namespace != null) {
            name = root_namespace.remove_vala_namespace (name);
        }
        return name;
    }

    /**
     * Remove the Class name from a function name
     */
    public string remove_namespace (Typescript.Namespace ? root_namespace, string vala_full_name) {
        return Typescript.remove_namespace (vala_full_name, this.get_name (root_namespace));
    }

    /**
     * Basesd on libvaladoc/api/interface.vala
     */
    public override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._interface.accessibility.to_string (); // "public" or "private"

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" * @interface as abstract class\n", false);
        signature.append (" */\n", false);

        signature.append ("export");
        signature.append_keyword ("abstract class");
        // signature.append_keyword ("interface");
        signature.append_symbol (this._interface);

        var type_parameters = this._interface.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                if (param is Valadoc.Api.TypeParameter) {
                    var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
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
        if (this._interface.base_type != null && this._interface.base_type is Valadoc.Api.TypeReference) {
            signature.append ("extends");

            var base_type = (Valadoc.Api.TypeReference) this._interface.base_type;
            var ts_base_type = new Typescript.TypeReference (base_type);

            signature.append_content (ts_base_type.get_signature (root_namespace));
            first = false;
        }

        //
        // Extended interfaces
        //
        var interfaces = this._interface.get_implemented_interface_list ();
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
        var properties = this._interface.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        foreach (var _prop in properties) {
            var prop = (Valadoc.Api.Property)_prop;
            var ts_prop = new Typescript.Property (prop);
            signature.append_content (ts_prop.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Methods
        //
        var methods = this._interface.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var m in methods) {
            // Typescript.Interface? iface_param = null;
            // iface_param = this;
            var ts_m = new Typescript.Method (m as Valadoc.Api.Method, null, this, null, null, null);
            signature.append_content (ts_m.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}