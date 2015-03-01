/*
	This module is for tokenizing classes.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.classtokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer Imports
// N/A


// name, base
/**
*	Class tuple.
*/
alias AClassTuple = Tuple!(string,string);

/**
*	Tokenizes a class.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Class tuple for the class.
*/
auto tokenizeClass(string fileName, size_t lineNumber, string input) {
	AClassTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!endsWith(input, ":")) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Does not end with ':'");
		return errorReturn;
	}
	
	auto classData = split(input, "(");
	if (classData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Multiple '('");
		return errorReturn;
	}
	
	string baseName;
	if (classData[1] != ":") {
		// parameters ...
		if (!endsWith(classData[1], ":")) {
			reportError(fileName, lineNumber, "Invalid Class Syntax", "':' location invalid.");
			return errorReturn;
		}
		baseName = classData[1][0 .. $-1];
	}
	else if (!endsWith(input, "(:")) { // No bases, but invalid syntax ...
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Does not end with '(:'");
		return errorReturn;
	}
	
	auto classInfo = split(classData[0], " ");
	if (classInfo.length != 2) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Invalid class data!");
		return errorReturn;
	}
	
	if (classInfo[0] != "class") {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Not a class.");
		return errorReturn;
	}
	
	AClassTuple returnClass;
	returnClass[0] = classInfo[1];
	returnClass[1] = baseName;
	return returnClass;
}