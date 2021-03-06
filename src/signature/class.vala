public class Typescript.Class : Typescript.Signable {
    protected Valadoc.Api.Class cl;

    public Class (Valadoc.Api.Class cl) {
        this.cl = cl;
    }

    public string get_name () {
        return this.cl.name;
    }

    /**
     * Basesd on libvaladoc/api/class.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this.cl.accessibility.to_string (); // "public" or "private"

        // TODO comments builder
        signature.append ("\n/**\n", false);
        signature.append (" * @" + accessibility + "\n", false);
        signature.append (" */\n", false);

        signature.append ("export");

        if (this.cl.is_abstract) {
            signature.append_keyword ("abstract");
        }
        if (this.cl.is_sealed) {
            signature.append_keyword ("/* sealed */");
        }
        signature.append_keyword ("class");
        signature.append (this.get_name ());

        var type_parameters = this.cl.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
        if (type_parameters.size > 0) {
            signature.append ("<", false);
            bool first = true;
            foreach (Valadoc.Api.Item param in type_parameters) {
                var ts_param = new Typescript.TypeParameter (param as Valadoc.Api.TypeParameter);
                if (!first) {
                    signature.append (",", false);
                }
                signature.append_content (ts_param.get_signature (root_namespace), false);
                first = false;
            }
            signature.append (">", false);
        }

        //
        // Extended classes
        //
        bool first = true;
        if (this.cl.base_type != null) {
            signature.append ("extends");

            var ts_base_type = new Typescript.TypeReference (this.cl.base_type as Valadoc.Api.TypeReference);

            signature.append_content (ts_base_type.get_signature (root_namespace));
            first = false;
        }

        //
        // Implemented interfaces
        //
        var interfaces = this.cl.get_implemented_interface_list ();
        if (interfaces.size > 0) {
            signature.append ("implements");

            first = true;

            foreach (Valadoc.Api.Item implemented_interface in interfaces) {
                if (!first) {
                    signature.append (",", false);
                }
                var ts_implemented_interface = new Typescript.TypeReference (implemented_interface as Valadoc.Api.TypeReference);
                signature.append_content (ts_implemented_interface.get_signature (root_namespace));
                first = false;
            }
        }

        // START Body
        signature.append_content ("{\n");

        //
        // Properties
        //
        var properties = cl.get_children_by_types ({ Valadoc.Api.NodeType.PROPERTY }, false);
        foreach (var prop in properties) {
            var ts_prop = new Typescript.Property (prop as Valadoc.Api.Property);
            signature.append_content (ts_prop.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Constructors
        //
        var constructors = cl.get_children_by_types ({ Valadoc.Api.NodeType.CREATION_METHOD }, false);
        foreach (var constr in constructors) {
            var ts_constr = new Typescript.Method (constr as Valadoc.Api.Method);
            signature.append_content (ts_constr.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Static Methods
        //
        var static_methods = cl.get_children_by_types ({ Valadoc.Api.NodeType.STATIC_METHOD }, false);
        foreach (var m in static_methods) {
            var ts_m = new Typescript.Method (m as Valadoc.Api.Method);
            signature.append_content (ts_m.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Methods
        //
        var methods = cl.get_children_by_types ({ Valadoc.Api.NodeType.METHOD }, false);
        foreach (var m in methods) {
            var ts_m = new Typescript.Method (m as Valadoc.Api.Method);
            signature.append_content (ts_m.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Delegate
        //
        var delegates = cl.get_children_by_types ({ Valadoc.Api.NodeType.DELEGATE }, false);
        foreach (var dele in delegates) {
            var ts_dele = new Typescript.Delegate (dele as Valadoc.Api.Delegate);
            signature.append_content (ts_dele.get_signature (root_namespace));
            signature.append ("\n", false);
        }

        //
        // Signals
        //
        var signals = cl.get_children_by_types ({ Valadoc.Api.NodeType.SIGNAL },false);
        foreach (var sig in signals) {
            var ts_sig = new Typescript.Signal (sig as Valadoc.Api.Signal,this);
            signature.append_content (ts_sig.get_signature (root_namespace));
            signature.append ("\n",false);
        }

        // END Body
        signature.append_content ("}\n");

        return signature.to_string ();
    }
}