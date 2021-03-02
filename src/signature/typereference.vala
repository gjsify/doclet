public class Typescript.TypeReference {
    protected Valadoc.Api.TypeReference type_ref;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public TypeReference (Valadoc.Api.TypeReference type_ref) {
        this.type_ref = type_ref;
    }

	public string get_signature() {
		string result;
		if (this.signature.to_string().length <= 0) {
			result = build_signature();
		} else {
			result = this.signature.to_string();
		}
		//  if (result.index_of(nspace.name) == 0) {
		//  	result = result.substring(0, nspace.name.length - 1);
		//  }
		return result;
	}

    /**
     * Basesd on libvaladoc/api/typereference.vala
     */
	 protected string build_signature () {
        if (this.type_ref.is_dynamic) {
			this.signature.append_keyword ("dynamic");
		}

		if (this.type_ref.is_weak) {
			this.signature.append_keyword ("weak");
		} else if (this.type_ref.is_owned) {
			this.signature.append_keyword ("owned");
		} else if (this.type_ref.is_unowned) {
			this.signature.append_keyword ("unowned");
		}

		if (this.type_ref.data_type == null) {
			this.signature.append_keyword ("void");
		} else if (this.type_ref.data_type is Valadoc.Api.Symbol) {
			
			this.signature.append (this.type_ref.data.to_string()); // => Gtk.Widget
			// this.signature.append_type ((Valadoc.Api.Symbol) this.type_ref.data_type);  // => Widget
		} else {
			this.signature.append_content (@"TODO $(this.type_ref.data_type.get_type())" /*this.type_ref.data_type.signature*/);
		}

		var type_arguments = this.type_ref.get_type_arguments();
		if (type_arguments.size > 0) {
			this.signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item _param in type_arguments) {
				var param  = (Valadoc.Api.TypeReference) _param;
				var ts_param = new TypeReference(param);
				if (!first) {
					this.signature.append (",", false);
				}
				this.signature.append_content (ts_param.build_signature(), false);
				first = false;
			}
			this.signature.append (">", false);
		}

		if (this.type_ref.is_nullable) {
			this.signature.append ("?", false);
		}
		return this.signature.to_string();
	}

}