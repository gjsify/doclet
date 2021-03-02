public class Typescript.Interface {
    protected Valadoc.Api.Interface iface;

	protected Typescript.SignatureBuilder _signature = new Typescript.SignatureBuilder ();

    public Interface (Valadoc.Api.Interface iface) {
        this.iface = iface;
    }

	public string get_signature() {
		if (this._signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this._signature.to_string();
		}
	}

     /**
     * Basesd on libvaladoc/api/interface.vala
     */
	 public string build_signature () {

		this._signature.append_keyword (this.iface.accessibility.to_string ());
		this._signature.append_keyword ("interface");
		this._signature.append_symbol (this.iface);

		var type_parameters = this.iface.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
		if (type_parameters.size > 0) {
			this._signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item _param in type_parameters) {
				var param = (Valadoc.Api.TypeParameter) _param;
				var ts_param = new Typescript.TypeParameter(param);
				if (!first) {
					this._signature.append (",", false);
				}
				this._signature.append_content (ts_param.get_signature(), false);
				first = false;
			}
			this._signature.append (">", false);
		}

		bool first = true;
		if (this.iface.base_type != null) {
			this._signature.append (":");

			var base_type = (Valadoc.Api.TypeReference) this.iface.base_type;
			var ts_base_type = new Typescript.TypeReference(base_type);

			this._signature.append_content (ts_base_type.get_signature());
			first = false;
		}

		var interfaces = this.iface.get_implemented_interface_list();
		if (interfaces.size > 0) {
			if (first) {
				this._signature.append ("extends");
			}

			foreach (Valadoc.Api.Item _implemented_interface in interfaces) {
				if (!first) {
					this._signature.append (",", false);
				}
				var implemented_interface = (Valadoc.Api.TypeReference) _implemented_interface;
				var ts_implemented_interface = new Typescript.TypeReference(implemented_interface);
				this._signature.append_content (ts_implemented_interface.get_signature());
				first = false;
			}
		}
		return this._signature.to_string();
	}

}