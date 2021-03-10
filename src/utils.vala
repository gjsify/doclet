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

    public string ? get_path (string[] search_dirs, string filename) {
        if (filename == null) {
            return null;
        }

        foreach (string dir in search_dirs) {
            string path = Path.build_path (Path.DIR_SEPARATOR_S, dir, filename);
            if (FileUtils.test (path, FileTest.EXISTS)) {
                return path;
            }
        }

        return null;
    }

    public string join (string[] strings, string divider = ", ") {
        string result = "";
        foreach (var str in strings) {
            result += (str + divider);
        }
        return result;
    }

    public string join_list (Vala.List<string> strings, string divider = ", ") {
        var strings_arr = strings.to_array ();
        if (strings_arr != null) {
            return Typescript.join (strings_arr, divider);
        }
        return "";
    }

    public bool contains (string[] strings, string search) {
        foreach (var str in strings) {
            if (search == str) {
                return true;
            }
        }
        return false;
    }

    /**
     * Remove the Class name from a function name
     */
    public string remove_namespace (string full_symbol_name, string ns) {
        var root_prefix = ns + ".";
        string result = full_symbol_name;

        if (full_symbol_name == null) {
            stderr.printf ("WARNING: full_symbol_name is null!");
            return result;
        }
        if (ns == null) {
            stderr.printf ("WARNING: namespace is null!");
            return result;
        }

        if (full_symbol_name.has_prefix (root_prefix)) {
            result = full_symbol_name.substring (root_prefix.length);
        }
        return result;
    }

    public bool has_parent_namespace (string name) {
        return name.index_of_char ('.') >= 0;
    }
}