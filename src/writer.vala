public class Typescript.Writer {
	public string filename;
	public string mode;

	private FileStream? stream;

	public Writer (string filename, string mode) {
		this.filename = filename;
		this.mode = mode;
	}

	public bool open () {
		stream = FileStream.open (filename, mode);
		return stream != null;
	}

	public void close () {
		stream = null;
	}

	public void write_line (string line) {
		stream.puts (line);
		stream.putc ('\n');
	}

}