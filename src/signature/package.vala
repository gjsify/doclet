public class Typescript.Package {
    public Valadoc.Api.Package package;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();
	
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

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
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
	protected string build_signature () {
		var dependencies = this.package.get_full_dependency_list(); // Or get_dependency_list
		this.signature.append(@"dep length: $(dependencies.size)", false);

		// DODO why is the size of dependencies 0?
		foreach (var package in dependencies) {
			var ts_dependency = new Typescript.Dependency(package);
			if (package.is_package) {
				this.signature.append(@"$(ts_dependency.get_signature())\n", false);
			} else {
				this.signature.append(@"$(ts_dependency.get_signature())\n", false);
			}
		}

		return this.signature.to_string();
	}

}