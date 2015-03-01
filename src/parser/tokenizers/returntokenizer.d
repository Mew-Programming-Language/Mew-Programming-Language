/*
	This module is for tokenizing return statements.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.returntokenizer;

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
*	Return Tuple
*/
alias AReturnTuple = Tuple!(string);

/**
*	Tokenizes a return expression.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Return tuple for the return statement.
*/
auto tokenizeReturn(string fileName, size_t lineNumber, string input) {
	AReturnTuple errorReturn;
	errorReturn[0] = null;
	
	auto returnData = split(input, " ");
	if (returnData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Return Syntax", "No spaces or more than one space.");
		return errorReturn;
	}
	
	if (returnData[0] != "return") {
		reportError(fileName, lineNumber, "Invalid Return Syntax", "Not a return statement.");
		return errorReturn;
	}
	
	AReturnTuple returnStatement;
	returnStatement[0] = returnData[1];
	return returnStatement;
}