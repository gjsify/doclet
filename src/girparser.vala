
/**
 * Uses GXml
 * @see Examples on https://gitlab.gnome.org/GNOME/gxml/-/tree/master/examples
 * @see Documentation on https://valadoc.org/gxml-0.20/index.htm
 */
public class Typescript.GirParser {

	/**
	* streamFile:
	* @uri: the file name to parse
	*
	* Parse and print information about an XML file.
	*/
	static void read(string uri) {

		var file = File.new_for_path (uri);
		GXml.Document doc;
		try {
			doc = new GXml.Document.from_file (file);
		} catch (GLib.Error error) {
			stdout.printf("Error: %s\n", error.message);
			return;
		}

		print("base_uri: " + doc.base_uri);
	
	}

}