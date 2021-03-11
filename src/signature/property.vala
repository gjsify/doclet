public class Typescript.Property : Typescript.Signable {
    protected Valadoc.Api.Property _property;
    Typescript.Signable ? parent_symbol = null;

    public Property (Typescript.Namespace ? root_namespace, Valadoc.Api.Property _property, Typescript.Signable ? parent_symbol) {
        this.root_namespace = root_namespace;
        this._property = _property;
        this.parent_symbol = parent_symbol;
    }

    public string ? get_parent_type () {
        if (this.parent_symbol != null) {
            if (this.parent_symbol is Typescript.Interface) {
                return "interface";
            }
            if (this.parent_symbol is Typescript.Class) {
                return "class";
            }
            if (this.parent_symbol is Typescript.Struct) {
                return "struct";
            }
            if (this.parent_symbol is Typescript.Enum) {
                return "enum";
            }
            if (this.parent_symbol is Typescript.ErrorDomain) {
                return "errordomain";
            }
        }

        return "unknown";
    }

    public override string get_name () {
        return this._property.name;
    }

    public string get_accessibility () {
        return this._property.accessibility.to_string ();
    }

    public bool is_public () {
        return this.get_accessibility () == "public";
    }

    /**
     * Basesd on libvaladoc/api/property.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        var accessibility = this.get_accessibility ();
        if (this.get_parent_type () == "class") {
            signature.append_keyword (accessibility);
        } else {
            signature.append_keyword (@"/* $(accessibility) */");
        }

        if (this._property.is_abstract) {
            signature.append_keyword ("/* abstract */");
        } else if (this._property.is_override) {
            signature.append_keyword ("/* override */");
        } else if (this._property.is_virtual) {
            signature.append_keyword ("/* virtual */");
        }

        // Write only
        if (this._property.getter == null && this._property.setter != null) {
            // TODO setter?
        }

        // Read only
        if (this._property.getter != null && this._property.setter == null) {
            signature.append ("readonly");
        }


        signature.append (this.get_name ());

        signature.append (":", false);

        var type = this._property.property_type;
        var ts_type = new Typescript.TypeReference (this.root_namespace, type);
        signature.append_content (ts_type.get_signature () /*this._property.property_type.signature*/);

        // signature.append (";", false);


        return signature.to_string ();
    }
}