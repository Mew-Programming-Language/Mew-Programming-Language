/*
	This module is for tokenizing structs.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.structtokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer Imports
// N/A

// name
/**
*	Struct tuple
*/
alias AStructTuple = Tuple!(string);

/**
*	Tokenizes a struct.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Struct tuple for the struct.
*/
auto tokenizeStruct(string fileName, size_t lineNumber, string input) {
	AStructTuple errorReturn;
	errorReturn[0] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!endsWith(input, "(:")) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Does not end with '(:'");
		return errorReturn;
	}
	
	auto structData = split(input, "(");
	if (structData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Multiple '('");
		return errorReturn;
	}
	
	auto structInfo = split(structData[0], " ");
	if (structInfo.length != 2) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Invalid struct information.");
		return errorReturn;
	}
	
	if (structInfo[0] != "struct") {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Not a struct");
		return errorReturn;
	}
	
	AStructTuple returnStruct;
	returnStruct[0] = structInfo[1];
	return returnStruct;
}