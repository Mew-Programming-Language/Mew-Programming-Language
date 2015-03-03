module parser.parserhandlers;

/**
*	Enumeration for scoped parsing types.
*/
enum ParserType {
	_module,
	_struct,
	_class,
	_task,
	_if,
	_else
}

const ubyte NOTHING = 0;
const ubyte CONTINUE = 1;
const ubyte BREAK = 2;
const ubyte RETURN = 3;

/**
*	Mixin template for scoped parser handlers.
*/
mixin template ParseHandler(ParserType ptype) {
	import std.stdio : writefln;
	/**
	*	Handling the specific scope parser.
	*	Params:
	*		lineNumber =	The current line number.
	*	Returns: Return code for what to do when returned.
	*/
	ubyte handleParser(ref size_t lineNumber) {
		line = strip(line, '\t');
		line = strip(line, ' ');
		line = strip(line, '\r');
		if (!line || !line.length) {
			lineNumber++;
			return CONTINUE;
		}
		
		// This is for parser debugging ...
		writefln("Parser: '%s' Line: '%s' LineNumber: '%s'", parserName, line, lineNumber);
	
		static if (ptype == ParserType._module) {
			// Checks if the line is the module aliasing ...
			if (line == "module " ~ m_module.name) {
				lineNumber++;
				return CONTINUE;
			}
		}
		
		// Checks for single line comment
		if (line[0] == '#') {
			lineNumber++;
			return CONTINUE;
		}
			
		// Checks for multi line comment
		if (inMultiLineComment) {
			if (line == "+/")
				inMultiLineComment = false;
			lineNumber++;
			return CONTINUE;
		}
		else if (line == "/+") {
			inMultiLineComment = true;
			lineNumber++;
			return CONTINUE;
		}
			
		static if (ptype == ParserType._task) {
			// Checks if it's an ending statement
			if (line == ")") {
				foundEndStatement = true;
				// RAII clean up .. (Also include this for all child scopes
				return BREAK;
			}
		}
		else static if (ptype == ParserType._if || ptype == ParserType._else) {
			// Checks if it's an ending statement
			if (line == ")") {
				m_task.addExp(new DirectExpression("}"));
				if (nextLine && nextLine.length && startsWith(nextLine, "elif")) {
					lineNumber++;
					return CONTINUE;
				}
				else if (nextLine && nextLine.length && nextLine == "else (:" && ptype == ParserType._if) {
					lineNumber += 2; // skips current line & the "else (:"
					m_task.addExp(new DirectExpression("else {"));
					mixin ElseStatement;
					handleElseStatement();
					return RETURN;
				}
				foundEndStatement = true;
				// RAII clean up .. (Also include this for all child scopes
				return BREAK;
			}
		}
		else static if (ptype == ParserType._struct ||
			ptype == ParserType._class) {
			// Checks if it's an ending statement
			if (line == ")") {
				foundEndStatement = true;
				return BREAK;
			}
		}
				
		// Replaces alias expressions
		foreach (k, v; aliases) {
			line = replace(line, k, v); // store information about alias + line later to report errors that are based on aliases
		}
		
		static if (ptype == ParserType._module ||
			ptype == ParserType._struct ||
			ptype == ParserType._class) {
			// Attribute handling
			if (resetAttributes)
				attributes = null;
				
			if (line[0] == '@') {
				attributes ~= line;
				lineNumber++;
				resetAttributes = false;
				return CONTINUE;
			}
			else
				resetAttributes = true;
		}
		
		static if (ptype == ParserType._module ||
			ptype == ParserType._struct ||
			ptype == ParserType._class) {	
			bool wasModifier = false;
			switch (line) {
				// ModifierAccess1
				case "public:":
					modifier1 = ModifierAccess1._public;
					wasModifier = true;
					break;
				case "protected:":
					modifier1 = ModifierAccess1._protected;
					wasModifier = true;
					break;
				case "private:":
					modifier1 = ModifierAccess1._private;
					wasModifier = true;
					break;
				case "personal:":
					modifier1 = ModifierAccess1._personal;
					wasModifier = true;
					break;
					
				// ModifierAccess2
				case "none:":
					modifier2 = ModifierAccess2.none;
					wasModifier = true;
					break;
				case "const:":
					modifier2 = ModifierAccess2._const;
					wasModifier = true;
					break;
				case "immutable:":
					modifier2 = ModifierAccess2._immutable;
					wasModifier = true;
					break;
				case "scope:":
					modifier2 = ModifierAccess2._scope;
					wasModifier = true;
					break;
				
				// Clear
				case "clear:":
					modifier1 = ModifierAccess1._public;
					modifier2 = ModifierAccess2.none;
					wasModifier = true;
					break;
				
				// not a modifier access
				default: break;
			}
			if (wasModifier) {
				lineNumber++;
				return CONTINUE;
			}
		}
		
		static if (ptype == ParserType._class) {
			if (startsWith(line, "this(") && endsWith(line, ":")) { // constructor ...
				line = "task " ~ line; // makes it valid for parsing ...
				source[lineNumber] = line;
				isConstructor = true;
			}
		}
		static if (ptype == ParserType._class || ptype == ParserType._struct) {
			if (startsWith(line, "~this(") && endsWith(line, ":")) { // destructor ...
				line = "task __free_" ~ line[1 .. $]; // makes it valid for parsing ...
				source[lineNumber] = line;
				isConstructor = true;
			}
		}
		
		return NOTHING;
	}
}