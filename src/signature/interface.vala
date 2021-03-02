public class Typescript.Interface {
    protected Valadoc.Api.Interface iface;

	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Interface (Valadoc.Api.Interface iface) {
        this.iface = iface;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

     /**
     * Basesd on libvaladoc/api/interface.vala
     */
	 public string build_signature () {

		var accessibility = this.iface.accessibility.to_string (); // "public" or "private"

		// TODO comments builder
		this.signature.append("\n/**\n", false);
		this.signature.append(" * @" + accessibility + "\n", false);
		this.signature.append(" */\n", false);

		this.signature.append_keyword ("interface");
		this.signature.append_symbol (this.iface);

		var type_parameters = this.iface.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
		if (type_parameters.size > 0) {
			this.signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item _param in type_parameters) {
				var param = (Valadoc.Api.TypeParameter) _param;
				var ts_param = new Typescript.TypeParameter(param);
				if (!first) {
					this.signature.append (",", false);
				}
				this.signature.append_content (ts_param.get_signature(), false);
				first = false;
			}
			this.signature.append (">", false);
		}

		//
		// Extended class
		//
		bool first = true;
		if (this.iface.base_type != null) {
			this.signature.append ("extends");

			var base_type = (Valadoc.Api.TypeReference) this.iface.base_type;
			var ts_base_type = new Typescript.TypeReference(base_type);

			this.signature.append_content (ts_base_type.get_signature());
			first = false;
		}

		//
		// Extended interfaces
		//
		var interfaces = this.iface.get_implemented_interface_list();
		if (interfaces.size > 0) {
			if (first) {
				this.signature.append ("extends");
			}

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
		var properties = iface.get_children_by_types ({Valadoc.Api.NodeType.PROPERTY}, false);
		foreach (var _prop in properties) {
			var prop = (Valadoc.Api.Property) _prop;
			var ts_prop = new Typescript.Property(prop); 
			this.signature.append_content (ts_prop.get_signature());
			this.signature.append ("\n", false);
		}

		//
		// Methods
		//
		var methods = iface.get_children_by_types ({Valadoc.Api.NodeType.METHOD}, false);
		foreach (var _m in methods) {
			var m = (Valadoc.Api.Method) _m;
			var ts_m = new Typescript.Method(m); 
			this.signature.append_content (ts_m.get_signature());
			this.signature.append ("\n", false);
		}

		// END Body
		this.signature.append_content ("}\n");

		return this.signature.to_string();
	}

}