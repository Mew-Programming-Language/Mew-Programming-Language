/*
	Error handling module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module errors.report;

// Std Imports
import std.stdio;
import std.string : format;

/**
*	Flag for errors.
*/
private bool _errors = false;
@property {
	/**
	*	Gets a boolean determining whether there was errors compiling or not.
	*/
	bool hasErrors() { return _errors; }
}

/**
*	Reports a compiler error to the standard error stream.
*	Params:
*		fileName =		The file containing the error.
*		line =			The line of the error.
*		errorName =		The name of the error.
*		errorText =		The text of the error.
*/
void reportError(string fileName, size_t line, string errorName, string errorText) {
	if (line == size_t.max)
		stderr.writefln("[File: %s Line: %s]", fileName, 0);
	else
		stderr.writefln("[File: %s Line: %s]", fileName, line + 1);
	stderr.writefln("[Error: %s]%s", errorName, errorText);
	_errors = true;
}