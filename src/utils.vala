namespace Typescript {
	public bool package_exists (string package_name, Valadoc.ErrorReporter reporter) {
		// copied from vala/codegen/valaccodecompiler.vala
		string pc = "pkg-config --exists " + package_name;
		int exit_status;

		try {
			Process.spawn_command_line_sync (pc, null, null, out exit_status);
			return (0 == exit_status);
		} catch (SpawnError e) {
			reporter.simple_warning ("GtkDoc", "Error pkg-config --exists %s: %s", package_name, e.message);
			return false;
		}
	}

}