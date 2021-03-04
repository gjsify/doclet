public class Typescript.Struct : Typescript.Signable {
    protected Valadoc.Api.Struct struc;

    public Struct (Valadoc.Api.Struct struc) {
        this.struc = struc;
    }

    /**
     * Basesd on libvaladoc/api/struct.vala
     */
	 protected override string build_signature () {
		this.signature
		.append_keyword (this.struc.accessibility.to_string ());
		this.signature.append_keyword ("struct");
		this.signature.append_symbol (this.struc);

		var type_parameters = this.struc.get_children_by_type (Valadoc.Api.NodeType.TYPE_PARAMETER, false);
		if (type_parameters.size > 0) {
			this.signature.append ("<", false);
			bool first = true;
			foreach (Valadoc.Api.Item param in type_parameters) {
				if (!first) {
					this.signature.append (",", false);
				}
				var ts_param = new Typescript.Parameter(param as Valadoc.Api.Parameter);
				this.signature.append_content (ts_param.get_signature(), false);
				first = false;
			}
			this.signature.append (">", false);
		}

		if (this.struc.base_type != null) {
			this.signature.append (":");

			var ts_base_type = new Typescript.TypeReference(this.struc.base_type as Valadoc.Api.TypeReference);
			this.signature.append_content (ts_base_type.get_signature());
		}

		return this.signature.to_string();
	}

}