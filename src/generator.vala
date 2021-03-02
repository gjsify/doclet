public class Typescript.Generator : Valadoc.Api.Visitor {

	private Valadoc.ErrorReporter reporter;
	private Valadoc.Settings settings;
	private Valadoc.Api.Tree current_tree;

	// private Valadoc.Api.Class current_class;

	public bool execute (Valadoc.Settings settings, Valadoc.Api.Tree tree, Valadoc.ErrorReporter reporter) {
		this.settings = settings;
		this.reporter = reporter;
		this.current_tree = tree;

		tree.accept (this);

		// stdout.printf("execute: %s\n", (string) this.settings);
		return true;
	}

	/**
	 * Visit operation called for api trees.
	 *
	 * @param item a tree
	 */
	public override void visit_tree (Valadoc.Api.Tree tree) {
		tree.accept_children (this);
		// stdout.printf("visit_tree: %s\n", (string) tree);
	}

	/**
	 * Visit operation called for packages like gir-files and vapi-files.
	 *
	 * @param item a package
	 */
	public override void visit_package (Valadoc.Api.Package package) {
		package.accept_all_children (this);

		stdout.printf(@"visit_package: $(package.name)\n");
		stdout.printf(@"visit_package get_full_name: $(package.get_full_name())\n");


		//  string path = GLib.Path.build_filename (this.settings.path);
		//  string filepath = GLib.Path.build_filename (path, package.name + ".d.ts");

		//  DirUtils.create_with_parents (path, 0777);

		//  var writer = new Typescript.Writer (filepath, "a+");
		//  if (!writer.open ()) {
		//  	reporter.simple_error ("Typescript", "unable to open '%s' for writing", writer.filename);
		//  	return;
		//  }
	}

	/**
	 * Visit operation called for namespaces
	 *
	 * @param item a namespace
	 */
	public override void visit_namespace (Valadoc.Api.Namespace ns) {
		ns.accept_all_children (this);
	}

	/**
	 * Visit operation called for interfaces.
	 *
	 * @param item a interface
	 */
	public override void visit_interface (Valadoc.Api.Interface iface) {
		// stdout.printf("visit_interface: %s\n", (string) iface.name);

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


		var ts_iface = new Typescript.Interface(iface);
		var sig = ts_iface.get_signature();
		stdout.printf(@"$(sig)\n");

	}

	/**
	 * Visit operation called for classes.
	 *
	 * @param item a class
	 */
	public override void visit_class (Valadoc.Api.Class cl) {
		// stdout.printf("visit_class: %s\n", (string) cl.name);

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


		var ts_class = new Typescript.Class(cl);
		var sig = ts_class.get_signature();
		stdout.printf(@"$(sig)\n");

	}

	/**
	 * Visit operation called for structs.
	 *
	 * @param item a struct
	 */
	public override void visit_struct (Valadoc.Api.Struct st) {
		// stdout.printf("visit_struct: %s\n", (string) st.name);
		st.accept_all_children (this);
	}

	/**
	 * Visit operation called for properties.
	 *
	 * @param item a property
	 */
	public override void visit_property (Valadoc.Api.Property prop) {
		// stdout.printf("visit_property: %s\n", (string) prop.name);
		// stdout.printf(@"$(prop.name), ");
		prop.accept_all_children (this);
	}

	/**
	 * Visit operation called for fields.
	 *
	 * @param item a field
	 */
	public override void visit_field (Valadoc.Api.Field f) {
		// stdout.printf("visit_field: %s\n", (string) f.name);
		f.accept_all_children (this);
	}

	/**
	 * Visit operation called for constants.
	 *
	 * @param item a constant
	 */
	public override void visit_constant (Valadoc.Api.Constant cons) {
		// stdout.printf("visit_constant: %s\n", (string) cons.name);
		cons.accept_all_children (this);
	}

	/**
	 * Visit operation called for delegates.
	 *
	 * @param item a delegate
	 */
	public override void visit_delegate (Valadoc.Api.Delegate dele) {
		// stdout.printf("visit_delegate: %s\n", (string) dele.name);
		dele.accept_children ({Valadoc.Api.NodeType.FORMAL_PARAMETER, Valadoc.Api.NodeType.TYPE_PARAMETER}, this);
	}

	/**
	 * Visit operation called for signals.
	 *
	 * @param item a signal
	 */
	public override void visit_signal (Valadoc.Api.Signal sig) {
		// stdout.printf("visit_signal: %s\n", (string) sig.name);
		sig.accept_all_children (this);
	}

	/**
	 * Visit operation called for methods.
	 *
	 * @param item a method
	 */
	public override void visit_method (Valadoc.Api.Method m) {
		// stdout.printf("visit_method: %s\n", (string) m.name);
		// m.accept_children ({NodeType.FORMAL_PARAMETER, NodeType.TYPE_PARAMETER}, this);
		

		if (!m.is_static && !m.is_constructor) {
			// stdout.printf(@"$(m.name) (");
			m.accept_all_children (this);
			// stdout.printf(@"): $(m.return_type.data.type_name)\n");
		}
	}

	/**
	 * Visit operation called for type parameters.
	 *
	 * @param item a type parameter
	 */
	public override void visit_type_parameter (Valadoc.Api.TypeParameter param) {
		// stdout.printf("visit_type_parameter: %s\n", (string) param.name);
		if (param.name != null) {
			// stdout.printf(@" $(param.data.type_name),");
		}
		
		param.accept_all_children (this);
	}

	/**
	 * Visit operation called for parameters.
	 *
	 * @param item a parameter
	 */
	public override void visit_formal_parameter (Valadoc.Api.Parameter param) {
		// stdout.printf("visit_formal_parameter: %s\n", (string) param.name);
		if (param.name != null) {
			// stdout.printf(@" $(param.name): $(param.data.type_name)");
		}
		
		param.accept_all_children (this);
	}

	/**
	 * Visit operation called for error domains.
	 *
	 * @param item a error domain
	 */
	public override void visit_error_domain (Valadoc.Api.ErrorDomain edomain) {
		// stdout.printf("visit_error_domain: %s\n", (string) edomain.name);
		edomain.accept_all_children (this);
	}

	/**
	 * Visit operation called for error codes.
	 *
	 * @param item a error code
	 */
	public override void visit_error_code (Valadoc.Api.ErrorCode ecode) {
		// stdout.printf("visit_error_code: %s\n", (string) ecode.name);
		ecode.accept_all_children (this);
	}

	/**
	 * Visit operation called for enums.
	 *
	 * @param item a enum
	 */
	public override void visit_enum (Valadoc.Api.Enum en) {
		// stdout.printf("visit_enum: %s\n", (string) en.name);
		en.accept_all_children (this);
	}

	/**
	 * Visit operation called for enum values.
	 *
	 * @param item a enum value
	 */
	public override void visit_enum_value (Valadoc.Api.EnumValue eval) {
		// stdout.printf("visit_enum_value: %s\n", (string) eval.name);
		eval.accept_all_children (this);
	}

	/**
	 * Visit abstract methods
	 */
	private void visit_abstract_method (Valadoc.Api.Method m) {
		// stdout.printf(@"abstract $(m.name)");
		if (!m.is_static && !m.is_constructor) {
			// stdout.printf(@"$(m.name) (");
			m.accept_all_children (this);
			// stdout.printf(@"): $(m.return_type.data.type_name)\n");
		}
	}

	/**
	 * Visit abstract properties
	 */
	private void visit_abstract_property (Valadoc.Api.Property prop) {
		// stdout.printf("visit_abstract_property: %s\n", (string) prop.name);
		prop.accept_all_children (this);
	}


}