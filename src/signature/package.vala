public class Typescript.Package : Typescript.Signable {
    public Valadoc.Api.Package package;
	
	public Typescript.Namespace ns;
	public string version;
	public Vala.ArrayList<Typescript.Class> classes = new Vala.ArrayList<Typescript.Class> ();
	public Vala.ArrayList<Typescript.Interface> ifaces = new Vala.ArrayList<Typescript.Interface> ();
	public Vala.ArrayList<Typescript.Constant> constants = new Vala.ArrayList<Typescript.Constant> ();
	public Vala.ArrayList<Typescript.Enum> enums = new Vala.ArrayList<Typescript.Enum> ();
	public Vala.ArrayList<Typescript.Struct> structs = new Vala.ArrayList<Typescript.Struct> ();
	public Vala.ArrayList<Typescript.ErrorDomain> error_domains = new Vala.ArrayList<Typescript.ErrorDomain> ();
	public Vala.ArrayList<Typescript.Method> functions = new Vala.ArrayList<Typescript.Method> ();

    public Package (Valadoc.Api.Package package) {
        this.package = package;
		this.set_version();
    }

	protected void set_version() {
		if (this.ns == null) {
			return;
		}
		var nspace = this.ns.nspace.data.to_string();
		var i = nspace.last_index_of_char('-');
		stdout.printf("nspace: " + nspace);
		stdout.printf("i: " + i.to_string());
		//  if (i >= 0) {
		//  	this.version = nspace.substring(i);
		//  }
	}


    /**
     * Basesd on libvaladoc/api/package.vala
	 * @note You need to passt "--deps" to valadoc to get dependencies, TODO not working?
     */
	protected override string build_signature () {
		foreach (var iface in this.ifaces) {
			this.signature.append_line(iface.get_signature());
		}

		foreach (var cls in this.classes) {
			this.signature.append_line(cls.get_signature());
		}

		//  foreach (var constant in this.constants) {
		//  	this.signature.append_line(constant.get_signature());
		//  }

		//  foreach (var enm in this.enums) {
		//  	this.signature.append_line(enm.get_signature());
		//  }

		foreach (var strct in this.structs) {
			this.signature.append_line(strct.get_signature());
		}

		foreach (var error_domain in this.error_domains) {
			this.signature.append_line(error_domain.get_signature());
		}

		foreach (var func in this.functions) {
			this.signature.append_line(func.get_signature());
		}

		return this.signature.to_string();
	}

}