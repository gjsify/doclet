public class Typescript.Class {
    protected Valadoc.Api.Class cl;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Class (Valadoc.Api.Class cl) {
        this.cl = cl;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/class.vala
     */
	protected string build_signature () {

		var accessibility = this.cl.accessibility.to_string (); // "public" or "private"
		
		// TODO comments builder
		this.signature.append("\n/**\n");
		this.signature.append(" * @" + accessibility + "\n");
		this.signature.append(" */\n");

		if (this.cl.is_abstract) {
			this.signature.append_keyword ("abstract");
		}
		if (this.cl.is_sealed) {
			this.signature.append_keyword ("sealed");
		}
		this.signature.append_keyword ("class");
		this.signature.append_symbol (this.cl);

		var type_parameters = this.cl.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

		bool first = true;
		if (this.cl.base_type != null) {
			this.signature.append ("extends");

			var base_type = (Valadoc.Api.TypeReference) this.cl.base_type;
			var ts_base_type = new Typescript.TypeReference(base_type);

			this.signature.append_content (ts_base_type.get_signature());
			first = false;
		}

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
		this.signature.append_content ("{");

		// TODO body

		this.signature.append_content ("}");

		return this.signature.to_string();
	}

}