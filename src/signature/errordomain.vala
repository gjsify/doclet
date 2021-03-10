public class Typescript.ErrorDomain : Typescript.Signable {
    protected Valadoc.Api.ErrorDomain _error_domain;

    public ErrorDomain (Typescript.Namespace ? root_namespace, Valadoc.Api.ErrorDomain error_domain) {
        this.root_namespace = root_namespace;
        this._error_domain = error_domain;
    }

    /**
     * Get error codes
     */
    public Vala.ArrayList<Typescript.ErrorCode> get_values () {
        var values = this._error_domain.get_children_by_types ({ Valadoc.Api.NodeType.ERROR_CODE }, false);
        Vala.ArrayList<Typescript.ErrorCode> ts_values = new Vala.ArrayList<Typescript.ErrorCode> ();
        foreach (var val in values) {
            var ts_val = new Typescript.ErrorCode (this.root_namespace, val as Valadoc.Api.ErrorCode);
            ts_values.add (ts_val);
        }
        return ts_values;
    }

    public string build_values_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var ts_enum_values = this.get_values ();

        foreach (var ts_enum in ts_enum_values) {
            signature.append_content (ts_enum.get_signature ());
            signature.append (",\n", false);
        }
        return signature.to_string ();
    }

    public string get_name () {
        return root_namespace.remove_vala_namespace (this._error_domain.get_full_name ());
    }

    /**
     * We exporting Error Domains as Enums
     * Basesd on libvaladoc/api/errordomain.vala
     */
    protected override string build_signature () {
        if (this._error_domain.get_full_name () == null) {
            return "";
        }
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this._error_domain.accessibility.to_string (); // private || public || protected
        return signature
                .append_keyword (accessibility == "public" ? "export" : "")
                .append_keyword ("enum")
                .append (this.get_name ())
                .append ("{\n")
                .append (this.build_values_signature ())
                .append_line ("}")
                .to_string ();

        // var signature = new Typescript.SignatureBuilder ();
        // return signature.append_keyword (this._error_domain.accessibility.to_string ())
        // .append_keyword ("errordomain")
        // .append_symbol (this._error_domain)
        // .to_string ();
    }
}