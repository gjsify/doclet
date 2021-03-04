public abstract class Typescript.Signable {
    protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();


    public string get_signature () {
        if (this.signature.to_string ().length <= 0) {
            return build_signature ();
        } else {
            return this.signature.to_string ();
        }
    }

    /**
     * Basesd on libvaladoc/api/array.vala
     */
    public abstract string build_signature ();
}