
/**
 * Provides a mechanism to inspect the API & documentation of programs and libraries
 * @see https://gitlab.gnome.org/GNOME/vala/-/blob/master/valadoc/doclets/gtkdoc/doclet.vala
 */

public class Typescript.Doclet : Valadoc.Doclet, Object {
 
	private Valadoc.ErrorReporter reporter;
	private Valadoc.Settings settings;
	private Valadoc.Api.Tree tree;
	private Typescript.Generator generator;

	/**
	 * Allows the doclet to inspect the given {@link Valadoc.Api.Tree}
	 *
	 * @param settings various configurations
	 * @param tree the tree to inspect
	 * @param reporter the reporter to use
	 * @see Content.ContentVisitor
	 * @see Api.Visitor
	 */
	public void process (Valadoc.Settings settings, Valadoc.Api.Tree tree, Valadoc.ErrorReporter reporter) {
		this.settings = settings;
		this.reporter = reporter;
		this.tree = tree;

		this.scangobj();

		stdout.printf("settings:\n");
		stdout.printf("    path: %s\n", settings.path);
		stdout.printf("    pkg_name: %s\n", settings.pkg_name);
		stdout.printf("    pkg_version: %s\n", settings.pkg_version);
		stdout.printf("    wiki_directory: %s\n", settings.wiki_directory);
		// stdout.printf("    pluginargs: %s\n", settings.pluginargs);
		stdout.printf("    private: %s\n", settings._private.to_string());
		stdout.printf("    protected: %s\n", settings._protected.to_string());
		stdout.printf("    internal: %s\n", settings._internal.to_string());
		stdout.printf("    with_deps: %s\n", settings.with_deps.to_string());
		stdout.printf("    add_inherited: %s\n", settings.add_inherited.to_string());
		stdout.printf("    verbose: %s\n", settings.verbose.to_string());
		stdout.printf("    experimental: %s\n", settings.experimental.to_string());
		stdout.printf("    experimental_non_null: %s\n", settings.experimental_non_null.to_string());
		// stdout.printf("    profile: %s\n", settings.profile);
		stdout.printf("    basedir: %s\n", settings.basedir);
		stdout.printf("    directory: %s\n", settings.directory);
		// stdout.printf("    defines: %s\n", settings.defines);
		// stdout.printf("    vapi_directories: %s\n", settings.vapi_directories);
		// stdout.printf("    packages: %s\n", settings.packages);
		// stdout.printf("    source_files: %s\n", settings.source_files);
		// stdout.printf("    gir_directory: %s\n", settings.gir_directory);
		stdout.printf("    gir_name: %s\n", settings.gir_name);
		// stdout.printf("    metadata_directories: %s\n", settings.metadata_directories);
		// stdout.printf("    alternative_resource_dirs: %s\n", settings.alternative_resource_dirs);
		// stdout.printf("    gir_directories: %s\n", settings.gir_directories);
		stdout.printf("    target_glib: %s\n", settings.target_glib);
		stdout.printf("    gir_namespace: %s\n", settings.gir_namespace);
		stdout.printf("    gir_version: %s\n", settings.gir_version);
		stdout.printf("    use_svg_images: %s\n", settings.use_svg_images.to_string());

		this.generator = new Typescript.Generator ();
		if (!this.generator.execute (settings, tree, reporter)) {
			return;
		}
	}

	private bool scangobj () {
		foreach (var package in this.tree.get_package_list()) {
			if (package.is_package && package_exists (package.name, reporter)) {
				// pc += package.name;
				stdout.printf("scangobj package: %s\n", package.name);
			}
		}
		return true;
	}

}
 
public Type register_plugin (Valadoc.ModuleLoader module_loader) {
	return typeof (Typescript.Doclet);
}
