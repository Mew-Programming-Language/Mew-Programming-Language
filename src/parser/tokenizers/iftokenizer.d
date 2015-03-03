/*
	This module is for tokenizing if/elif statements.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.iftokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer Imports
import parser.tokenizers.expressiontokenizer;

// leftHand, operator, rightHand
/**
*	If Tuple.
*/
alias AIfTuple = Tuple!(string,string,string);

/**
*	Tokenizes an if (or elif) expression.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: If tuple for the class.
*/
auto tokenizeIf(string fileName, size_t lineNumber, string input) {
	AIfTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	errorReturn[2] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid If/Elif Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!endsWith(input, ":")) {
		reportError(fileName, lineNumber, "Invalid If/Elif Syntax", "Does not end with ':'");
		return errorReturn;
	}
	
	auto ifData = split(input, "(");
	if (ifData.length != 2) {
		reportError(fileName, lineNumber, "Invalid If/Elif Syntax", "Multiple '('");
		return errorReturn;
	}
	
	if (!endsWith(ifData[1], ":")) {
		reportError(fileName, lineNumber, "Invalid If/Elif Syntax", "Does not end with :");
		return errorReturn;
	}
	
	string lorExp = ifData[1][0 .. $-1]; // Selects the lor expression
	auto lorExpression = tokenizeExpression3!true(fileName, lineNumber, lorExp);

	if (!lorExpression[0]) {
		return errorReturn; // Invalid lor expression. tokenizeExpression3 reports the error.
	}
	
	string statement = strip(ifData[0], ' ');
	statement = strip(statement, '\t');
	
	if (statement != "if" && statement != "elif") {
		reportError(fileName, lineNumber, "Invalid If/Elif Syntax", "Not an if or elif statement.");
		return errorReturn;
	}
	
	AIfTuple ifReturn;
	ifReturn[0] = lorExpression[0];
	ifReturn[1] = lorExpression[1];
	ifReturn[2] = lorExpression[2];
	return ifReturn;
}