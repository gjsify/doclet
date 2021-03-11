public class Typescript.ErrorCode : Typescript.Signable {
    protected Valadoc.Api.ErrorCode _error_code;

    public ErrorCode (Typescript.Namespace ? root_namespace, Valadoc.Api.ErrorCode error_code) {
        this.root_namespace = root_namespace;
        this._error_code = error_code;
    }

    public override string get_name () {
        return this._error_code.name;
    }

    /**
     * Returns the name of this class as it is used in C.
     */
    public string get_cname () {
        return this._error_code.get_cname ();
    }

    /**
     * Returns the dbus-name.
     */
    public string get_dbus_name () {
        return this._error_code.get_dbus_name ();
    }

    /**
     * Basesd on libvaladoc/api/errorcode.vala
     */
    protected override string build_signature () {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_symbol (this._error_code);
        return signature.to_string ();
    }
}