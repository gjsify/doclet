public class Typescript.Signal {
    protected Valadoc.Api.Signal sig;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Signal (Valadoc.Api.Signal sig) {
        this.sig = sig;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
	}

    /**
     * Basesd on libvaladoc/api/signal.vala
     */
	 protected string build_signature () {
		this.signature.append_keyword (this.sig.accessibility.to_string ());
		if (this.sig.is_virtual) {
			signature.append_keyword ("virtual");
		}

		signature.append_keyword ("signal");

		var ts_return_type = new Typescript.TypeReference(this.sig.return_type as Valadoc.Api.TypeReference);
		signature.append_content (ts_return_type.get_signature());
		signature.append_symbol (this.sig);
		signature.append ("(");

		bool first = true;
		foreach (Valadoc.Api.Node param in this.sig.get_children_by_type (Valadoc.Api.NodeType.FORMAL_PARAMETER, false)) {
			if (!first) {
				signature.append (",", false);
			}
			var ts_param = new Typescript.Parameter(param as Valadoc.Api.Parameter);
			signature.append_content (ts_param.get_signature(), !first);
			first = false;
		}

		signature.append (")", false);

		return this.signature.to_string();
	}

}