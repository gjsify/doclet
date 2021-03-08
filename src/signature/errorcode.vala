public class Typescript.ErrorCode : Typescript.Signable {
    protected Valadoc.Api.ErrorCode _error_code;

    public ErrorCode (Valadoc.Api.ErrorCode error_code) {
        this._error_code = error_code;
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
    protected override string build_signature (Typescript.Namespace ? root_namespace) {
        var signature = new Typescript.SignatureBuilder ();
        signature.append_symbol (this._error_code);
        return signature.to_string ();
    }
}