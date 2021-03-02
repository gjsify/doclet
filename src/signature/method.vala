public class Typescript.Method {
    protected Valadoc.Api.Method m;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Method (Valadoc.Api.Method m) {
        this.m = m;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/Method.vala
     */
	 protected string build_signature () {
		this.signature.append_keyword (this.m.accessibility.to_string ());

		// TODO comments builder


		if (!this.m.is_constructor) {
			if (this.m.is_static) {
				this.signature.append_keyword ("static");
			} else if (this.m.is_class) {
				this.signature.append_keyword ("class");
			} else if (this.m.is_abstract) {
				this.signature.append_keyword ("abstract");
			} else if (this.m.is_override) {
				this.signature.append_keyword ("override");
			} else if (this.m.is_virtual) {
				this.signature.append_keyword ("virtual");
			}
			if (this.m.is_inline) {
				this.signature.append_keyword ("inline");
			}
		}

		if (this.m.is_yields) {
			this.signature.append_keyword ("async");
		}

		this.signature.append_symbol (this.m);

		var type_parameters = this.m.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

		this.signature.append ("(");

		bool first = true;
		foreach (Valadoc.Api.Node _param in this.m.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
			var param = (Valadoc.Api.Parameter) _param;
			var ts_param = new Typescript.Parameter(param);
			if (!first) {
				this.signature.append (",", false);
			}
			this.signature.append_content (ts_param.get_signature(), !first);
			first = false;
		}

		this.signature.append (")", false);

		//
		// Return type
		//
		if (!this.m.is_constructor) {
			this.signature.append (":", false);

			var return_type = (Valadoc.Api.TypeReference) this.m.return_type;
			var ts_return_type = new Typescript.TypeReference(return_type);

			this.signature.append_content (ts_return_type.get_signature());
		}

		var exceptions = this.m.get_children_by_types ({Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS});
		if (exceptions.size > 0) {
			signature.append_keyword ("throws");
			first = true;
			foreach (Valadoc.Api.Node param in exceptions) {
				if (!first) {
					signature.append (",", false);
				}
				signature.append_type (param);
				first = false;
			}
		}

		return this.signature.to_string();
	}

}