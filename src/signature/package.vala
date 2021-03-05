public class Typescript.Package : Typescript.Signable {
	protected Valadoc.Settings settings;
	protected Typescript.GirParser gir_parser;
	protected Vala.CodeContext context;
	protected Vala.ArrayList<Typescript.Package> dependencies = new Vala.ArrayList<Typescript.Package> ();
	protected Vala.SourceFile? source_file;
	public Valadoc.Api.Package package;
	public Typescript.Namespace root_namespace;
	public Typescript.Namespace current_namespace;
	public Vala.ArrayList<Typescript.Class> classes = new Vala.ArrayList<Typescript.Class> ();
	public Vala.ArrayList<Typescript.Interface> ifaces = new Vala.ArrayList<Typescript.Interface> ();
	public Vala.ArrayList<Typescript.Constant> constants = new Vala.ArrayList<Typescript.Constant> ();
	public Vala.ArrayList<Typescript.Enum> enums = new Vala.ArrayList<Typescript.Enum> ();
	public Vala.ArrayList<Typescript.Struct> structs = new Vala.ArrayList<Typescript.Struct> ();
	public Vala.ArrayList<Typescript.ErrorDomain> error_domains = new Vala.ArrayList<Typescript.ErrorDomain> ();
	public Vala.ArrayList<Typescript.Method> functions = new Vala.ArrayList<Typescript.Method> ();

    public Package (Valadoc.Settings settings, Vala.CodeContext context, Typescript.GirParser gir_parser, Valadoc.Api.Package package) {
		this.settings = settings;
        this.package = package;
		this.context = context;
		this.gir_parser = gir_parser;
		this.source_file = this.get_source_file();
		// Use this if we need more informations from the gir files
		// this.gir_parser.load_by_package(this);
    }

	public string? get_vala_namespace() {
		if (this.root_namespace != null) {
			return this.root_namespace.vala_namespace.get_full_name();
		}
		return null;
	}

	public string get_gir_namespace() {
		return this.source_file.gir_namespace;
	}

	public string get_gir_version() {
		return this.source_file.gir_version;
	}

	public string get_vala_package_name() {
		if (this.source_file != null) {
			return this.source_file.package_name;
		}
		return this.package.name;
	}

	public string get_gir_package_name() {
		return this.get_gir_namespace() + "-" + this.get_gir_version();
	}

	public string get_vapi_filename() {
		if (this.source_file != null) {
			return this.source_file.filename;
		}
		return this.get_vala_package_name() + ".vapi";
	}

	public string get_gir_filename() {
		return this.get_gir_package_name() + ".gir";
	}

	/**
	 * See also https://github.com/flobrosch/valadoc-org/blob/master/src/generator.vala#L412
	 */
	public string get_vapi_path() {
		string? result = null;
		if (this.source_file != null) {
			result = this.source_file.get_relative_filename();
		}
		if (result == null) {
			result = Typescript.get_path(this.settings.vapi_directories, this.get_vapi_filename());
		}
		return result;
	}

	/**
	 * See also https://github.com/flobrosch/valadoc-org/blob/master/src/generator.vala#L381
	 */
	public string? get_gir_path () {
		return Typescript.get_path(this.settings.gir_directories, this.get_gir_filename());
	}

	public void add_dependency(Typescript.Package pkg) {
		if (pkg == null) {
			return;
		}
		this.dependencies.add(pkg);
	}

	public Vala.ArrayList<Typescript.Package> get_dependency(Typescript.Package pkg) {
		return this.dependencies;
	}

	/**
	 * Specifies whether this package is a dependency
	 */
	public bool is_dependency() {
		return this.package.is_package;
	}

	public bool is_main() {
		return !this.is_dependency();
	}

	protected Vala.SourceFile? get_source_file() {
		var source_files = this.context.get_source_files();
		foreach (var source_file in source_files) {
			if (source_file.package_name == this.package.name) {
				return source_file;
			}
		}
		return null;
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

		foreach (var constant in this.constants) {
			this.signature.append_line(constant.get_signature());
		}

		foreach (var enm in this.enums) {
			this.signature.append_line(enm.get_signature());
		}

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