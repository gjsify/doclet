
/**
 * Provides a mechanism to inspect the API & documentation of programs and libraries
 * @see https://gitlab.gnome.org/GNOME/vala/-/blob/master/valadoc/doclets/gtkdoc/doclet.vala
 */

public class Typescript.Doclet : Valadoc.Doclet, Object {
 
	private Typescript.Reporter reporter;
	private Valadoc.Settings settings;
	private Valadoc.Api.Tree tree;
	private Typescript.Generator generator;
	private Typescript.GirParser gir_parser;

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
		this.tree = tree;
		this.reporter = new Typescript.Reporter(settings);
		this.gir_parser = GirParser.get_instance(this.settings, this.tree, this.reporter);

		this.generator = new Typescript.Generator ();
		if (!this.generator.execute (settings, tree, this.reporter, this.gir_parser)) {
			return;
		}

		this.reporter.simple_note("doclet process path", settings.path);
		this.reporter.simple_note("doclet process pkg_name", settings.pkg_name);
		this.reporter.simple_note("doclet process pkg_version", settings.pkg_version != null ? settings.pkg_version : "");
		this.reporter.simple_note("doclet process wiki_directory", settings.wiki_directory != null ? settings.wiki_directory : "");
		this.reporter.simple_note("doclet process pluginargs", Typescript.join(settings.pluginargs, ", "));
		this.reporter.simple_note("doclet process private", settings._private == true ? "true" : "false");
		this.reporter.simple_note("doclet process protected", settings._protected == true ? "true" : "false");
		this.reporter.simple_note("doclet process internal", settings._internal == true ? "true" : "false");
		this.reporter.simple_note("doclet process with_deps", settings.with_deps == true ? "true" : "false");
		this.reporter.simple_note("doclet process add_inherited", settings.add_inherited == true ? "true" : "false");
		this.reporter.simple_note("doclet process verbose", settings.verbose == true ? "true" : "false");
		this.reporter.simple_note("doclet process experimental", settings.experimental == true ? "true" : "false" );
		this.reporter.simple_note("doclet process experimental_non_null", settings.experimental_non_null == true ? "true" : "false");
		// this.reporter.simple_note("doclet process profile", settings.profile);
		this.reporter.simple_note("doclet process basedir", settings.basedir != null ? settings.basedir : "");
		this.reporter.simple_note("doclet process directory", settings.directory);
		this.reporter.simple_note("doclet process defines", Typescript.join(settings.defines, ", "));
		this.reporter.simple_note("doclet process vapi_directories", Typescript.join(settings.vapi_directories, ", "));
		this.reporter.simple_note("doclet process packages", Typescript.join(settings.packages, ", "));
		this.reporter.simple_note("doclet process source_files", Typescript.join(settings.source_files, ", "));
		this.reporter.simple_note("doclet process gir_directory", settings.gir_directory);
		this.reporter.simple_note("doclet process gir_name", settings.gir_name != null ? settings.gir_name : "");
		this.reporter.simple_note("doclet process metadata_directories", Typescript.join(settings.metadata_directories, ", "));
		this.reporter.simple_note("doclet process alternative_resource_dirs", Typescript.join(settings.alternative_resource_dirs, ", "));
		this.reporter.simple_note("doclet process gir_directories", Typescript.join(settings.gir_directories, ", "));
		this.reporter.simple_note("doclet process target_glib", settings.target_glib != null ? settings.target_glib : "");
		this.reporter.simple_note("doclet process gir_namespace", settings.gir_namespace != null ? settings.gir_namespace : "");
		this.reporter.simple_note("doclet process gir_version", settings.gir_version != null ? settings.gir_version : "");
		this.reporter.simple_note("doclet process use_svg_images", settings.use_svg_images == true ? "true" : "false");

		foreach (var package in this.tree.get_package_list()) {
			this.reporter.simple_note("scangobj", @"package: $(package.name)");
		}
	}

}
 
public Type register_plugin (Valadoc.ModuleLoader module_loader) {
	return typeof (Typescript.Doclet);
}
