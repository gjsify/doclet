public class Typescript.TypeReference : Typescript.Signable {
    protected Valadoc.Api.TypeReference type_ref;

    public TypeReference (Valadoc.Api.TypeReference type_ref) {
        this.type_ref = type_ref;
    }

    /**
     * Basesd on libvaladoc/api/typereference.vala
     */
	protected override string build_signature () {
        if (this.type_ref.is_dynamic) {
			this.signature.append_keyword ("/* dynamic */");
		}

		if (this.type_ref.is_weak) {
			this.signature.append_keyword ("/* weak */");
		} else if (this.type_ref.is_owned) {
			this.signature.append_keyword ("/* owned */");
		} else if (this.type_ref.is_unowned) {
			this.signature.append_keyword ("/* unowned */");
		}

		// Type
		string type;
		if (this.type_ref.data_type == null) {
			type = "void";
		} else if (this.type_ref.data_type is Valadoc.Api.Symbol) {
			var symbol = this.type_ref.data_type as Valadoc.Api.Symbol;
			type = symbol.get_full_name();
			// type = (this.type_ref.data.to_string()); // => Gtk.Widget
		} else {
			var ts_data_type = new Typescript.TypeReference (this.type_ref.data_type as Valadoc.Api.TypeReference);
			type = ts_data_type.get_signature();
		}

		if (type == null) {
			type = "any";
		}
		this.signature.append (type);

		var type_arguments = this.type_ref.get_type_arguments();
		if (type_arguments.size > 0) {
			this.signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item type_arg in type_arguments) {
				var ts_type_arg = new TypeReference(type_arg as Valadoc.Api.TypeReference);
				if (!first) {
					this.signature.append (",", false);
				}
				this.signature.append_content (ts_type_arg.build_signature(), false);
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