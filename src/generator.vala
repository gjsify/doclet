public class Typescript.Generator : Valadoc.Api.Visitor {

	private Typescript.Reporter reporter;
	private Valadoc.Settings settings;
	private Valadoc.Api.Tree current_tree;
	private Vala.ArrayList<Typescript.Package> packages = new Vala.ArrayList<Typescript.Package> ();
	private Typescript.Package current_package;
	private Typescript.Package main_package;
	private Typescript.Class current_class;
	private Typescript.Interface current_interface;


	public bool execute (Valadoc.Settings settings, Valadoc.Api.Tree tree, Typescript.Reporter reporter) {
		this.settings = settings;
		this.reporter = reporter;
		this.current_tree = tree;

		tree.accept (this);

		// this.reporter.simple_note("execute", "execute: %s", (string) this.settings);
		return true;
	}

	/**
	 * Visit operation called for api trees.
	 *
	 * @param item a tree
	 */
	public override void visit_tree (Valadoc.Api.Tree tree) {
		tree.accept_children (this);
		this.reporter.simple_note("visit_tree", "visit_tree");

		//  var packages = tree.get_package_list();
		//  foreach (var package in packages) {

		//  	this.reporter.simple_note("visit_tree", @"tree package: $(package.name)");
		//  	this.reporter.simple_note("visit_tree", @"tree package get_full_name: $(package.get_full_name())");
	
		//  	var ts_package = new Typescript.Package(package);
		//  	var signature = ts_package.get_signature();
		//  	this.reporter.simple_note("visit_tree", @"$(signature)");
		//  }


	}

	/**
	 * Visit operation called for packages like gir-files and vapi-files.
	 *
	 * @param item a package
	 */
	public override void visit_package (Valadoc.Api.Package package) {
		this.reporter.simple_note("visit_package START", package.name);

		// Resets
		this.current_class = null;
		this.current_interface = null;

		var ts_package = new Typescript.Package(package);

		this.current_package = ts_package;

		if (settings.pkg_name == package.name) {
			this.main_package = ts_package;
			package.accept_all_children (this);
		}

		if (settings.pkg_name != package.name) {
			this.packages.add(this.current_package);
		}
		
		// this.reporter.simple_note("visit_package END", package.get_full_name());

		string path = GLib.Path.build_filename (this.settings.path);
		string filepath = GLib.Path.build_filename (path, settings.pkg_name + ".d.ts");

		DirUtils.create_with_parents (path, 0777);

		var writer = new Typescript.Writer (filepath, "a+");
		if (!writer.open ()) {
			reporter.simple_error ("Typescript", "unable to open '%s' for writing", writer.filename);
			return;
		}

		writer.write(this.main_package.get_signature());

		//  var source = ts_package.package.get_source_file();
		//  this.reporter.simple_note("visit_package package_name", source.data.package_name);
		//  this.reporter.simple_note("visit_package get_csource_filename", source.data.get_csource_filename());
		//  this.reporter.simple_note("visit_package installed_version", source.data.installed_version);
		//  this.reporter.simple_note("visit_package gir_namespace", source.data.gir_namespace);
		//  this.reporter.simple_note("visit_package gir_version", source.data.gir_version);
		//  this.reporter.simple_note("visit_package file_type", source.data.file_type.to_string());
	}

	/**
	 * Visit operation called for namespaces
	 *
	 * @param item a namespace
	 */
	public override void visit_namespace (Valadoc.Api.Namespace ns) {

		if (!ns.is_browsable(this.settings)) {
			return;
		}

		// Is global namespace?
		if (ns.name == null)  {
			ns.accept_all_children (this);
			return;
		}

		// Resets
		this.current_class = null;
		this.current_interface = null;

		this.reporter.simple_note("visit_namespace START", ns.get_full_name());
		var ts_namespace = new Typescript.Namespace(ns);
		this.current_package.ns = ts_namespace;

		ns.accept_all_children (this);

		if (ns != null && ns.get_full_name() != null) {
			this.reporter.simple_note("visit_namespace START", ns.get_full_name());
		}

	}

	/**
	 * Visit operation called for interfaces.
	 *
	 * @param item a interface
	 */
	public override void visit_interface (Valadoc.Api.Interface iface) {
		this.reporter.simple_note("visit_interface", iface.get_full_name());

		var ts_iface = new Typescript.Interface(iface);
		this.current_interface = ts_iface;
		this.current_class = null;
		this.current_package.ifaces.add(ts_iface);

		iface.accept_all_children (this);

		var abstract_methods = iface.get_children_by_types ({Valadoc.Api.NodeType.METHOD}, false);
		foreach (var m in abstract_methods) {
			// List all protected methods, even if they're not marked as browsable
			if (m.is_browsable (this.settings) || ((Valadoc.Api.Symbol) m).is_protected) {
				this.visit_abstract_method ((Valadoc.Api.Method) m);
			}
		}

		var abstract_properties = iface.get_children_by_types ({Valadoc.Api.NodeType.PROPERTY}, false);
		foreach (var prop in abstract_properties) {
			// List all protected properties, even if they're not marked as browsable
			if (prop.is_browsable (this.settings) || ((Valadoc.Api.Symbol) prop).is_protected) {
				this.visit_abstract_property ((Valadoc.Api.Property) prop);
			}
		}

		//  var ts_iface = new Typescript.Interface(iface);
		//  var sig = ts_iface.get_signature();
		//  this.reporter.simple_note("visit_interface", @"$(sig)");
	}

	/**
	 * Visit operation called for classes.
	 *
	 * @param item a class
	 */
	public override void visit_class (Valadoc.Api.Class cl) {
		// this.reporter.simple_note("visit_class", "visit_class: %s", (string) cl.name);

		var ts_class = new Typescript.Class(cl);
		this.current_class = ts_class;
		this.current_interface = null;
		this.current_package.classes.add(ts_class);

		cl.accept_all_children (this);
	
		var abstract_methods = cl.get_children_by_types ({Valadoc.Api.NodeType.METHOD}, false);
		foreach (var m in abstract_methods) {
			// List all protected methods, even if they're not marked as browsable
			if (m.is_browsable (settings) || ((Valadoc.Api.Symbol) m).is_protected) {
				visit_abstract_method ((Valadoc.Api.Method) m);
			}
		}

		var abstract_properties = cl.get_children_by_types ({Valadoc.Api.NodeType.PROPERTY}, false);
		foreach (var prop in abstract_properties) {
			// List all protected properties, even if they're not marked as browsable
			if (prop.is_browsable (settings) || ((Valadoc.Api.Symbol) prop).is_protected) {
				visit_abstract_property ((Valadoc.Api.Property) prop);
			}
		}

		//  var ts_class = new Typescript.Class(cl);
		//  var sig = ts_class.get_signature();
		//  this.reporter.simple_note("visit_class", @"$(sig)");

	}

	/**
	 * Visit operation called for structs.
	 *
	 * @param item a struct
	 */
	public override void visit_struct (Valadoc.Api.Struct st) {
		// this.reporter.simple_note("visit_struct", "visit_struct: %s", (string) st.name);
		st.accept_all_children (this);
	}

	/**
	 * Visit operation called for properties.
	 *
	 * @param item a property
	 */
	public override void visit_property (Valadoc.Api.Property prop) {
		// this.reporter.simple_note("visit_property", "visit_property: %s", (string) prop.name);
		// this.reporter.simple_note("visit_property", @"$(prop.name), ");
		prop.accept_all_children (this);
	}

	/**
	 * Visit operation called for fields.
	 *
	 * @param item a field
	 */
	public override void visit_field (Valadoc.Api.Field f) {
		// this.reporter.simple_note("visit_field", "visit_field: %s", (string) f.name);
		f.accept_all_children (this);
	}

	/**
	 * Visit operation called for constants.
	 *
	 * @param item a constant
	 */
	public override void visit_constant (Valadoc.Api.Constant cons) {
		var ts_cons = new Typescript.Constant(cons as Valadoc.Api.Constant); 
		this.current_package.constants.add(ts_cons);
		cons.accept_all_children (this);
	}

	/**
	 * Visit operation called for delegates.
	 *
	 * @param item a delegate
	 */
	public override void visit_delegate (Valadoc.Api.Delegate dele) {
		// this.reporter.simple_note("visit_delegate", "visit_delegate: %s", (string) dele.name);
		dele.accept_children ({Valadoc.Api.NodeType.FORMAL_PARAMETER, Valadoc.Api.NodeType.TYPE_PARAMETER}, this);
	}

	/**
	 * Visit operation called for signals.
	 *
	 * @param item a signal
	 */
	public override void visit_signal (Valadoc.Api.Signal sig) {
		// this.reporter.simple_note("visit_signal", "visit_signal: %s", (string) sig.name);
		sig.accept_all_children (this);
	}

	/**
	 * Visit operation called for methods.
	 *
	 * @param item a method
	 */
	public override void visit_method (Valadoc.Api.Method m) {
		// this.reporter.simple_note("visit_method", "visit_method: %s", (string) m.name);
		// m.accept_children ({NodeType.FORMAL_PARAMETER, NodeType.TYPE_PARAMETER}, this);

		if (this.current_class == null && this.current_interface == null) {
			this.visit_function(m);
			return;
		}

		if (m.is_constructor) {
			this.visit_constructor(m);
			return;
		}

		m.accept_all_children (this);
		// this.reporter.simple_note("visit_method", @"): $(m.return_type.data.type_name)");
		
	}

	public void visit_static_method (Valadoc.Api.Method m) {

		m.accept_all_children (this);

	}

	public void visit_constructor (Valadoc.Api.Method m) {
		this.reporter.simple_note("visit_constructor", m.name);
		m.accept_all_children (this);
	}

	/**
	 * Global functions
	 */
	public void visit_function (Valadoc.Api.Method m) {
		this.reporter.simple_note("visit_function", m.name);
		var ts_m = new Typescript.Method(m as Valadoc.Api.Method); 
		this.current_package.functions.add(ts_m);
		m.accept_all_children (this);

	}

	/**
	 * Visit operation called for type parameters.
	 *
	 * @param item a type parameter
	 */
	public override void visit_type_parameter (Valadoc.Api.TypeParameter param) {
		// this.reporter.simple_note("visit_type_parameter", "visit_type_parameter: %s", (string) param.name);
		if (param.name != null) {
			// this.reporter.simple_note("visit_type_parameter", @" $(param.data.type_name),");
		}
		
		param.accept_all_children (this);
	}

	/**
	 * Visit operation called for parameters.
	 *
	 * @param item a parameter
	 */
	public override void visit_formal_parameter (Valadoc.Api.Parameter param) {
		// this.reporter.simple_note("visit_formal_parameter", "visit_formal_parameter: %s", (string) param.name);
		if (param.name != null) {
			// this.reporter.simple_note("visit_formal_parameter", @" $(param.name): $(param.data.type_name)");
		}
		
		param.accept_all_children (this);
	}

	/**
	 * Visit operation called for error domains.
	 *
	 * @param item a error domain
	 */
	public override void visit_error_domain (Valadoc.Api.ErrorDomain edomain) {
		// this.reporter.simple_note("visit_error_domain", "visit_error_domain: %s", (string) edomain.name);
		edomain.accept_all_children (this);
	}

	/**
	 * Visit operation called for error codes.
	 *
	 * @param item a error code
	 */
	public override void visit_error_code (Valadoc.Api.ErrorCode ecode) {
		// this.reporter.simple_note("visit_error_code", "visit_error_code: %s", (string) ecode.name);
		ecode.accept_all_children (this);
	}

	/**
	 * Visit operation called for enums.
	 *
	 * @param item a enum
	 */
	public override void visit_enum (Valadoc.Api.Enum en) {
		// this.reporter.simple_note("visit_enum", "visit_enum: %s", (string) en.name);
		en.accept_all_children (this);
	}

	/**
	 * Visit operation called for enum values.
	 *
	 * @param item a enum value
	 */
	public override void visit_enum_value (Valadoc.Api.EnumValue eval) {
		// this.reporter.simple_note("visit_enum_value", "visit_enum_value: %s", (string) eval.name);
		eval.accept_all_children (this);
	}

	/**
	 * Visit abstract methods
	 */
	private void visit_abstract_method (Valadoc.Api.Method m) {
		// this.reporter.simple_note("visit_abstract_method", @"abstract $(m.name)");
		if (!m.is_static && !m.is_constructor) {
			// this.reporter.simple_note("visit_abstract_method", @"$(m.name) (");
			m.accept_all_children (this);
			// this.reporter.simple_note("visit_abstract_method", @"): $(m.return_type.data.type_name)");
		}
	}

	/**
	 * Visit abstract properties
	 */
	private void visit_abstract_property (Valadoc.Api.Property prop) {
		// this.reporter.simple_note("visit_abstract_property", "visit_abstract_property: %s", (string) prop.name);
		prop.accept_all_children (this);
	}


}