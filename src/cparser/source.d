/*
	This module is for C source creation.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.source;

// Std Imports
import std.array : join;

// Mew Imports
import cparser.imports;
import cparser.variables;
import cparser.funcs;

/**
*	Creates a c source file code.
*	Params:
*		name =			The name of the source file.
*		_imports =		The imports of the source file.
*		_globals =		The globals of the source file.
*		_funcs =		The functions of the source file.
*	Returns: The c source code.
*/
string createSource(string name, Import[] _imports, Variable[] _globals, Func[] _funcs) {
	string[] content;
	if (_imports) {
		foreach (imp; _imports) {
			content ~= imp.toString();
		}
	}
	if (_globals) {
		foreach (global; _globals) {
			content ~= global.toSource();
		}
	}
	if (_funcs) {
		foreach (func; _funcs) {
			content ~= func.toSource();
		}
	}
	
	return join(content, "\r\n");
}