/**
 * Builds up a signature from the given items.
 * simplified version of libvaladoc/api/signaturebuilder.vala without formatted / highlighted text 
 */
public class Typescript.SignatureBuilder {
    protected StringBuilder content = new StringBuilder ();
    private string last_appended = "";

	public string to_string () {
		return this.content.str;
	}

	public string get () {
		return this.to_string();
	}

	private void append_text (string text) {
		this.last_appended = text;
		this.content.append(last_appended);
	}

	/**
	 * Adds text onto the end of the builder.
	 *
	 * @param text a string
	 * @param spaced add a space at the front of the string if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append (string text, bool spaced = true) {
		string content = (last_appended != null && spaced ? " " : "") + text;
		append_text (content);
		return this;
	}

	/**
	 * Adds text onto the end of the builder.
	 *
	 * @param text a string
	 * @param spaced add a space at the front of the string if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_attribute (string text, bool spaced = true) {
		return this.append(text, spaced);
	}

	/**
	 * Adds a Inline onto the end of the builder.
	 *
	 * @param content a content
	 * @param spaced add a space at the front of the inline if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_content (string content, bool spaced = true) {
		return this.append(content, spaced);
	}

	/**
	 * Adds a with new line onto the end of the builder.
	 *
	 * @param content a content
	 * @param spaced add a space at the front of the inline if necessary
	 * @return this
	 */
	 public unowned SignatureBuilder append_line (string content) {
		string new_line;
		if(this.last_appended.last_index_of_char('\n') == this.last_appended.length) {
			new_line = "\n" + content + "\n";
		} else {
			new_line = content;
		}
		
		return this.append(new_line, false);
	}

	/**
	 * Adds a keyword onto the end of the builder.
	 *
	 * @param keyword a keyword
	 * @param spaced add a space at the front of the keyword if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_keyword (string keyword, bool spaced = true) {
		return this.append(keyword, spaced);
	}

	/**
	 * Adds a symbol onto the end of the builder.
	 *
	 * @param node a node
	 * @param spaced add a space at the front of the node if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_symbol (Valadoc.Api.Node node, bool spaced = true) {
		return this.append (node.name, spaced);
	}

	/**
	 * Adds a type onto the end of the builder.
	 *
	 * @param node a node
	 * @param spaced add a space at the front of the node if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_type (Valadoc.Api.Node node, bool spaced = true) {
		return this.append (node.name, spaced);
	}

	/**
	 * Adds a type name onto the end of the builder.
	 *
	 * @param name a type name
	 * @param spaced add a space at the front of the type name if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_type_name (string name, bool spaced = true) {
		return this.append (name, spaced);
	}

	/**
	 * Adds a literal onto the end of the builder.
	 *
	 * @param literal a literal
	 * @param spaced add a space at the front of the literal if necessary
	 * @return this
	 */
	public unowned SignatureBuilder append_literal (string literal, bool spaced = true) {
		return this.append (literal, spaced);
	}
}