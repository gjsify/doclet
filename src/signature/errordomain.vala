public class Typescript.ErrorDomain : Typescript.Signable {
    protected Valadoc.Api.ErrorDomain _error_domain;

    public ErrorDomain (Valadoc.Api.ErrorDomain error_domain) {
        this._error_domain = error_domain;
    }

    /**
     * Get error codes
     */
    public Vala.ArrayList<Typescript.ErrorCode> get_values (Typescript.Namespace ? root_namespace) {
        var values = this._error_domain.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_CODE }, false);
        Vala.ArrayList<Typescript.ErrorCode> ts_values = new Vala.ArrayList<Typescript.ErrorCode> ();
        foreach (var val in values) {
            var ts_val = new Typescript.ErrorCode (val as Valadoc.Api.ErrorCode);
            ts_values.add (ts_val);
        }
        return ts_values;
    }

    public string build_values_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        var ts_enum_values = this.get_values (root_namespace);

        foreach (var ts_enum in ts_enum_values) {
            signature.append_content (ts_enum.get_signature (root_namespace));
            signature.append (",\n", false);
        }
        return signature.to_string ();
    }

    public string get_name (Typescript.Namespace ? root_namespace) {
        return root_namespace.remove_vala_namespace (this._error_domain.get_full_name ());
    }

    /**
     * We exporting Error Domains as Enums
     * Basesd on libvaladoc/api/errordomain.vala
     */
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        if (this._error_domain.get_full_name () == null) {
            return "";
        }
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._error_domain.accessibility.to_string (); // private || public || protected
        return signature
                .append_keyword (accessibility == "public" ? "export" : "")
                .append_keyword ("enum")
                .append (this.get_name (root_namespace))
                .append ("{\n")
                .append (this.build_values_signature (root_namespace))
                .append_line ("}")
                .to_string ();

        // var signature = new Typescript.SignatureBuilder ();
        // return signature.append_keyword (this._error_domain.accessibility.to_string ())
        // .append_keyword ("errordomain")
        // .append_symbol (this._error_domain)
        // .to_string ();
    }
}