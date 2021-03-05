
public class Typescript.GirParser {

	Valadoc.Settings settings;
	Valadoc.Api.Tree tree;
	Typescript.Reporter reporter;
	static Typescript.GirParser instance;

	private GirParser(Valadoc.Settings settings, Valadoc.Api.Tree tree, Typescript.Reporter reporter) {
		this.settings = settings;
		this.tree = tree;
		this.reporter = reporter;
	}

	public static Typescript.GirParser get_instance(Valadoc.Settings? settings, Valadoc.Api.Tree? tree, Typescript.Reporter? reporter) {
		if (Typescript.GirParser.instance != null) {
			return Typescript.GirParser.instance;
		}
		return new Typescript.GirParser(settings, tree, reporter);
	}

	public void load_by_package(Typescript.Package pkg) {
		this.reporter.simple_note("load_by_package", pkg.get_gir_path());
		var doc = this.load_gir(pkg.get_gir_path());
		var tree = doc.document_element;
		var dependencies = tree.get_elements_by_tag_name("include");
		foreach (var dependency in dependencies) {
			var name = dependency.get_attribute("name");
			var version = dependency.get_attribute("version");
			this.reporter.simple_note("Dependency", name + "-" + version);
		}
		
	}

	/**
	* Uses GXml
	* @see Examples on https://gitlab.gnome.org/GNOME/gxml/-/tree/master/examples
	* @see Documentation on https://valadoc.org/gxml-0.20/index.htm
	*/
	protected GXml.Document? load_xml_file(string uri) {
		this.reporter.simple_note("load_xml_file uri", uri);
		var file = File.new_for_path (uri);
		GXml.Document? doc = null;
		try {
			doc = new GXml.Document.from_file (file);
		} catch (GLib.Error error) {
			stdout.printf("Error: %s\n", error.message);
		}
		return doc;	
	}

	protected GXml.Document? load_gir(string path) {
		var doc  = this.load_xml_file(path);
		return doc;
	}

}