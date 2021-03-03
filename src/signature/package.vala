public class Typescript.Package {
    protected Valadoc.Api.Package package;
	protected Typescript.SignatureBuilder signature = new Typescript.SignatureBuilder ();

    public Package (Valadoc.Api.Package package) {
        this.package = package;
    }

	public string get_signature() {
		if (this.signature.to_string().length <= 0) {
			return build_signature();
		} else {
			return this.signature.to_string();
		}
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

		this.signature.append(@"test", false);

		return this.signature.to_string();
	}

}