public class Typescript.Class : Typescript.Signable {
    protected Valadoc.Api.Class cl;

    public Class (Valadoc.Api.Class cl) {
        this.cl = cl;
    }

    /**
     * Basesd on libvaladoc/api/class.vala
     */
	protected override string build_signature () {

		var accessibility = this.cl.accessibility.to_string (); // "public" or "private"
		
		// TODO comments builder
		this.signature.append("\n/**\n", false);
		this.signature.append(" * @" + accessibility + "\n", false);
		this.signature.append(" */\n", false);

		this.signature.append ("export");

		if (this.cl.is_abstract) {
			this.signature.append_keyword ("abstract");
		}
		if (this.cl.is_sealed) {
			this.signature.append_keyword ("/* sealed */");
		}
		this.signature.append_keyword ("class");
		this.signature.append_symbol (this.cl);

		var type_parameters = this.cl.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
		if (type_parameters.size > 0) {
			this.signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item param in type_parameters) {
				var ts_param = new Typescript.TypeParameter(param as Valadoc.Api.TypeParameter);
				if (!first) {
					this.signature.append (",", false);
				}
				this.signature.append_content (ts_param.get_signature(), false);
				first = false;
			}
			this.signature.append (">", false);
		}

		//
		// Extended classes
		//
		bool first = true;
		if (this.cl.base_type != null) {
			this.signature.append ("extends");

			var ts_base_type = new Typescript.TypeReference(this.cl.base_type as Valadoc.Api.TypeReference);

			this.signature.append_content (ts_base_type.get_signature());
			first = false;
		}

		//
		// Implemented interfaces
		//
        var interfaces = this.cl.get_implemented_interface_list();
		if (interfaces.size > 0) {
			this.signature.append ("implements");

			first = true;

			foreach (Valadoc.Api.Item _implemented_interface in interfaces) {
				if (!first) {
					this.signature.append (",", false);
				}
				var implemented_interface = (Valadoc.Api.TypeReference) _implemented_interface;
				var ts_implemented_interface = new Typescript.TypeReference(implemented_interface);
				this.signature.append_content (ts_implemented_interface.get_signature());
				first = false;
			}
		}

		// START Body
		this.signature.append_content ("{\n");

		//
		// Properties
		//
		var properties = cl.get_children_by_types ({Valadoc.Api.NodeType.PROPERTY}, false);
		foreach (var prop in properties) {
			var ts_prop = new Typescript.Property(prop as Valadoc.Api.Property); 
			this.signature.append_content (ts_prop.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Constructors
		//
		var constructors = cl.get_children_by_types ({Valadoc.Api.NodeType.CREATION_METHOD}, false);
		foreach (var constr in constructors) {
			var ts_constr = new Typescript.Method(constr as Valadoc.Api.Method); 
			this.signature.append_content (ts_constr.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Static Methods
		//
		var static_methods = cl.get_children_by_types ({Valadoc.Api.NodeType.STATIC_METHOD}, false);
		foreach (var m in static_methods) {
			var ts_m = new Typescript.Method(m as Valadoc.Api.Method); 
			this.signature.append_content (ts_m.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Methods
		//
		var methods = cl.get_children_by_types ({Valadoc.Api.NodeType.METHOD}, false);
		foreach (var m in methods) {
			var ts_m = new Typescript.Method(m as Valadoc.Api.Method); 
			this.signature.append_content (ts_m.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Delegate
		//
		var delegates = cl.get_children_by_types ({Valadoc.Api.NodeType.DELEGATE}, false);
		foreach (var dele in delegates) {
			var ts_dele = new Typescript.Delegate(dele as Valadoc.Api.Delegate); 
			this.signature.append_content (ts_dele.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Signals
		//
		var signals = cl.get_children_by_types ({Valadoc.Api.NodeType.SIGNAL}, false);
		foreach (var sig in signals) {
			var ts_sig = new Typescript.Signal(sig as Valadoc.Api.Signal); 
			this.signature.append_content (ts_sig.get_signature());
			this.signature.append ("\n", false);
		}

		// END Body
		this.signature.append_content ("}\n");

		return this.signature.to_string();
	}

}