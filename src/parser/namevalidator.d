/*
	This module is for name validation for types.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.namevalidator;

// Std Imports
import std.algorithm : canFind, startsWith;
import std.array : split;
import std.string : format;

// Mew Imports
import errors.report;

/**
*	Validates a type name.
*	Params:
*		name =		The name to validate.
*		ignore =	Boolean determining whether it should ignore type-name conflicts.
*	Returns: True if the name is valid, false otherwise.
*/
bool validName(string name, bool ignore = false) {
	if (ignore) {
		return (isValidChars(name));
	}
	else {
		return (
			!isDataType(name) &&
			isValidChars(name) &&
			!startsWith(name, "__")
		);
	}
}

/**
*	Enumeration for datatypes.
*/
private enum DTs = [
	"import", "include", "cextern",
	"is", "null",
	"this", "~this", "super",
	"byte", "short", "int", "long",
	"ubyte", "ushort", "uint", "ulong",
	"float", "double", "real",
	"bool", "char", "string",
	"size_t", "ptrdiff_t",
	"array",
	"list",
	"map",
	"orderlist",
	"ordermap",
	"linklist",
	"stack",
	"queue"
];

/**
*	Checks whether an input string is a datatype.
*	Params:
*		S =	The input string.
*	Returns: True if the input string is a datatype.
*/
private bool isDataType(string S) {
	return canFind(DTs, S);
}

/**
*	Checks whether an input string is A-Z, 0-9 and "_"
*	Params:
*		S = The input string.
*	Returns: True if the input string is valid.
*/
private bool isValidChars(string S) {
	foreach (c; S) {
		if (!(c >= 65 && c <= 90) &&
			!(c >= 97 && c <= 122) &&
			!(c == 95) &&
			!(c >= 48 && c <= 57)) {
			return false;
		}
	}
	return true;
}