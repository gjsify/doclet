public class Typescript.Method : Typescript.Signable {
    protected Valadoc.Api.Method m;

    public Method (Valadoc.Api.Method m) {
        this.m = m;
    }

    /**
     * Basesd on libvaladoc/api/Method.vala
     */
	 protected override string build_signature () {
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
				this.signature.append_keyword ("/* override */");
			} else if (this.m.is_virtual) {
				this.signature.append_keyword ("/* virtual */");
			}
			if (this.m.is_inline) {
				this.signature.append_keyword ("/* inline */");
			}
		}

		if (this.m.is_yields) {
			this.signature.append_keyword ("async");
		}

		if (this.m.is_virtual) {
			this.signature.append ("vfunc_" + this.m.name);
		} else {
			this.signature.append (this.m.name);
		}

		var type_parameters = this.m.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
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

		this.signature.append ("(");

		bool first = true;
		foreach (Valadoc.Api.Node param in this.m.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
			var ts_param = new Typescript.Parameter(param as Valadoc.Api.Parameter);
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
			var ts_return_type = new Typescript.TypeReference(this.m.return_type as Valadoc.Api.TypeReference);
			this.signature.append_content (ts_return_type.get_signature());
		}

		var exceptions = this.m.get_children_by_types ({Valadoc.Api.NodeType.ERROR_DOMAIN, Valadoc.Api.NodeType.CLASS});
		if (exceptions.size > 0) {
			signature.append ("/*");
			signature.append_keyword ("throws");
			first = true;
			foreach (Valadoc.Api.Node param in exceptions) {
				if (!first) {
					signature.append (",", false);
				}
				signature.append_type (param);
				first = false;
			}
			signature.append ("*/");
		}

		this.signature.append (";", false);

		return this.signature.to_string();
	}

}