/*
	This module is for C header creation.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.header;

// Std Imports
import std.array : join;
import std.string : format, toUpper;

// Mew Imports
import cparser.imports;
import cparser.variables;
import cparser.structs;
import cparser.funcs;

/**
*	Creates the c header code.
*	Params:
*		name =			The name of the header.
*		_imports =		The imports of the header.
*		_globals =		The global variables of the header.
*		_structs =		The structs of the header.
*		_funcs =		The functions of the header.
*	Returns: The c header code.
*/
string createHeader(string name, Import[] _imports, Variable[] _globals, Struct[] _structs, Func[] _funcs) {
	string src = "#ifndef %s_H_INCLUDED
#define %s_H_INCLUDED

%s

#endif";
	
	string[] content;
	if (_imports) {
		foreach (imp; _imports) {
			content ~= imp.toString();
		}
	}
	if (_globals) {
		foreach (global; _globals) {
			content ~= global.toHeader();
		}
	}
	if (_structs) {
		foreach (strc; _structs) {
			content ~= strc.toString();
		}
	}
	if (_funcs) {
		foreach (func; _funcs) {
			content ~= func.toHeader();
		}
	}
	
	src = format(src, toUpper(name), toUpper(name), join(content, "\r\n"));
	return src;
}