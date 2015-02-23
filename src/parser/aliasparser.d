/*
	This module is for parsing aliases.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.aliasparser;

// Mew Imports
import errors.report;
import std.stdio;

/**
*	Parses an alias expression.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The line number.
*		line =			The current line.
*		lineSplit =		The line split.
*		aliases =		The alias collection.
*/
void parseAlias(string fileName, ref size_t lineNumber, string line, string[] lineSplit, ref string[string] aliases) {
	if (lineSplit.length < 3) {
		reportError(fileName, lineNumber, "Invalid Syntax", "Invalid alias syntax.");
	}
	else {
		string aliasName = lineSplit[1];
		size_t len = "alias".length + aliasName.length + 2;
		if (len >= line.length) {
			reportError(fileName, lineNumber, "Alias Expression", "No expression found.");
		}
		else {
			string expression = line[len .. $];
			aliases[aliasName] = expression;
		}
	}
}