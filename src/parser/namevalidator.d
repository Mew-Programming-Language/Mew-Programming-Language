module parser.namevalidator;

import std.algorithm : canFind, startsWith;

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

private enum DTs = [
	"is", "null", "this", "~this",
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
private bool isDataType(string S) {
	return canFind(DTs, S);
}

private bool isValidChars(string S) {
	foreach (c; S) {
		if (!(c >= 65 && c <= 90) &&
			!(c >= 97 && c <= 122) &&
			!(c == 95)) {
			return false;
		}
	}
	return true;
}