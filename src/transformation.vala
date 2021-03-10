namespace Typescript {

    public const string RESERVED_RENAME_PREFIX = "_";

    public const string[] RESERVED_VARIABLE_NAMES = {
        "in",
        "function",
        "true",
        "false",
        "break",
        "arguments",
        "eval",
        "default",
        "new",
        "extends",
        "with",
        "var",
        "class",
        "delete",
        "return",
        "this"
    };

    public const string[] RESERVED_SYMBOL_NAMES = {
        "break",
        "boolean",
        "case",
        "catch",
        "class",
        "const",
        "continue",
        "debugger",
        "default",
        "delete",
        "do",
        "else",
        "enum",
        "export",
        "extends",
        "false",
        "finally",
        "for",
        "function",
        "if",
        "implements",
        "import",
        "in",
        "instanceof",
        "interface",
        "let",
        "new",
        "number",
        "package",
        "private",
        "protected",
        "public",
        "return",
        "static",
        "super",
        "switch",
        "string",
        "this",
        "throw",
        "true",
        "try",
        "typeof",
        "var",
        "void",
        "while",
        "with",
        "yield"
    };

    public bool is_reserved_variable_name (string name) {
        return Typescript.contains (RESERVED_VARIABLE_NAMES, name);
    }

    public bool is_reserved_symbol_name (string name) {
        return Typescript.contains (RESERVED_SYMBOL_NAMES, name);
    }

    // See https://wiki.gnome.org/Projects/Vala/Manual/Types
    public string transform_type (string name) {
        Gee.HashMap<string, string> BASIC_TYPE_MAP = new Gee.HashMap<string, string> ();
        BASIC_TYPE_MAP.set ("bool", "boolean");

        // integral-types
        BASIC_TYPE_MAP.set ("char", "number");
        BASIC_TYPE_MAP.set ("uchar", "number");
        BASIC_TYPE_MAP.set ("short", "number");
        BASIC_TYPE_MAP.set ("ushort", "number");
        BASIC_TYPE_MAP.set ("int", "number");
        BASIC_TYPE_MAP.set ("uint", "number");
        BASIC_TYPE_MAP.set ("long", "number");
        BASIC_TYPE_MAP.set ("ulong", "number");
        BASIC_TYPE_MAP.set ("size_t", "number");
        BASIC_TYPE_MAP.set ("ssize_t", "number");
        BASIC_TYPE_MAP.set ("int8", "number");
        BASIC_TYPE_MAP.set ("uint8", "number");
        BASIC_TYPE_MAP.set ("int16", "number");
        BASIC_TYPE_MAP.set ("uint16", "number");
        BASIC_TYPE_MAP.set ("int32", "number");
        BASIC_TYPE_MAP.set ("uint32", "number");
        BASIC_TYPE_MAP.set ("int64", "number");
        BASIC_TYPE_MAP.set ("uint64", "number");
        BASIC_TYPE_MAP.set ("unichar", "number");

        // floating-point-types
        BASIC_TYPE_MAP.set ("float", "number");
        BASIC_TYPE_MAP.set ("double", "number");

        // reference-types
        BASIC_TYPE_MAP.set ("string", "string");

        // TODO
        BASIC_TYPE_MAP.set ("_string", "string");


        if (BASIC_TYPE_MAP.has_key (name)) {
            return BASIC_TYPE_MAP.get (name);
        }

        return name;
    }
}