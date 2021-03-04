
/**
 * Provides a mechanism to inspect the API & documentation of programs and libraries
 * @see https://gitlab.gnome.org/GNOME/vala/-/blob/master/valadoc/doclets/gtkdoc/doclet.vala
 */

public class Typescript.Doclet : Valadoc.Doclet, Object {
 
	private Typescript.Reporter reporter;
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
		this.reporter = new Typescript.Reporter(settings);
		this.tree = tree;

		this.scangobj();

		this.generator = new Typescript.Generator ();
		if (!this.generator.execute (settings, tree, this.reporter)) {
			return;
		}

		this.reporter.simple_note("doclet process", @"    path: $(settings.path)");
		this.reporter.simple_note("doclet process", @"    pkg_name: $(settings.pkg_name)");
		this.reporter.simple_note("doclet process", @"    pkg_version: $(settings.pkg_version != null ? settings.pkg_version : "")");
		this.reporter.simple_note("doclet process", @"    wiki_directory: $(settings.wiki_directory != null ? settings.wiki_directory : "")");
		// this.reporter.simple_note("doclet process", @"    pluginargs: $(settings.pluginargs)");
		this.reporter.simple_note("doclet process", @"    private: $(settings._private)");
		this.reporter.simple_note("doclet process", @"    protected: $(settings._protected)");
		this.reporter.simple_note("doclet process", @"    internal: $(settings._internal)");
		this.reporter.simple_note("doclet process", @"    with_deps: $(settings.with_deps)");
		this.reporter.simple_note("doclet process", @"    add_inherited: $(settings.add_inherited)");
		this.reporter.simple_note("doclet process", @"    verbose: $(settings.verbose)");
		this.reporter.simple_note("doclet process", @"    experimental: $(settings.experimental)");
		this.reporter.simple_note("doclet process", @"    experimental_non_null: $(settings.experimental_non_null)");
		this.reporter.simple_note("doclet process", @"    profile: $(settings.profile != null ? settings.profile : "")");
		this.reporter.simple_note("doclet process", @"    basedir: $(settings.basedir != null ? settings.basedir : "")");
		this.reporter.simple_note("doclet process", @"    directory: $(settings.directory)");
		// this.reporter.simple_note("doclet process", @"    defines: $(settings.defines)");
		// this.reporter.simple_note("doclet process", @"    vapi_directories: $(settings.vapi_directories)");
		// this.reporter.simple_note("doclet process", @"    packages: $(settings.packages)");
		// this.reporter.simple_note("doclet process", @"    source_files: $(settings.source_files)");
		// this.reporter.simple_note("doclet process", @"    gir_directory: $(settings.gir_directory)");
		this.reporter.simple_note("doclet process", @"    gir_name: $(settings.gir_name != null ? settings.gir_name : "")");
		// this.reporter.simple_note("doclet process", @"    metadata_directories: $(settings.metadata_directories)");
		// this.reporter.simple_note("doclet process", @"    alternative_resource_dirs: $(settings.alternative_resource_dirs)");
		// this.reporter.simple_note("doclet process", @"    gir_directories: $(settings.gir_directories)");
		this.reporter.simple_note("doclet process", @"    target_glib: $(settings.target_glib != null ? settings.target_glib : "")");
		this.reporter.simple_note("doclet process", @"    gir_namespace: $(settings.gir_namespace != null ? settings.gir_namespace : "")");
		this.reporter.simple_note("doclet process", @"    gir_version: $(settings.gir_version != null ? settings.gir_version : "")");
		this.reporter.simple_note("doclet process", @"    use_svg_images: $(settings.use_svg_images)");

	}

	private bool scangobj () {
		foreach (var package in this.tree.get_package_list()) {
			if (package.is_package && package_exists (package.name, reporter)) {
				// pc += package.name;
				this.reporter.simple_note("scangobj", @"package: $(package.name)");
			}
		}
		return true;
	}

}
 
public Type register_plugin (Valadoc.ModuleLoader module_loader) {
	return typeof (Typescript.Doclet);
}
