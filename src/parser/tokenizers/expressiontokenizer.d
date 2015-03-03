/*
	This module is for tokenizing expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.expressiontokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer Imports
// N/A

//	Note:
//		Expressions do not report errors due to the fact there might be multiple expression validations. Some may fail, while otherwise will succeed.

// leftHand, operator, rightHand, isCall, params
/**
*	Expression Tuple.
*/
alias AExpressionTuple = Tuple!(string,string,string,bool,string[]);

/**
*	Enumeration of LOR (set) operators.
*/
private enum AOperators1 = [
	// set
	"=",
	// art
	"+=", "-=", "*=", "/=",
	// bit
	"^="
];

/**
*	Enumeration of LOR (cmp) operators.
*/
private enum AOperators2 = [
	// equal
	"==",
	// not equal
	"!=",
	// above or equal
	">=",
	// below or equal
	"<=",
	// above
	">",
	// below
	"<"
	// is the same type
	"is",
	// is not the same type
	"!is"
];

/**
*	Tokenizes an expression. (leftHand, operator, rightHand)
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*		operators =		The operators to proceed with.
*	Returns: Expression tuple for the expression.
*/
auto tokenizeExpression1(string fileName, size_t lineNumber, string input, string[] operators) {
	AExpressionTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	errorReturn[2] = null;
	errorReturn[3] = false;
	errorReturn[4] = null;
	
	auto expData = split(input, " ");
	if (expData.length != 3) {
		return errorReturn;
	}
	
	if (!canFind(operators, expData[1])) {
		return errorReturn;
	}
	
	bool isCall = false;
	string name = expData[2];
	string[] params;
	if (canFind(expData[2], "(") &&
		endsWith(expData[2], ")")) {
		isCall = true;
		
		string callExpression = expData[2];
		
		/*if (startsWith(callExpression, "cast<")) {
			// do casting ...
			return errorReturn; // casting not implemented ...
		}*/
		
		if (endsWith(callExpression, "()")) {
			name = callExpression[0 .. $-2];
		}
		else {
			auto callData = split(callExpression, "(");
			if (callData.length != 2) {
				reportError(fileName, lineNumber, "Invalid Call Syntax", "Found multiple '('");
				return errorReturn;
			}
			else {
				if (!endsWith(callData[1], ")")) {
					reportError(fileName, lineNumber, "Invalid Call Syntax", "Does not end with ')'");
					return errorReturn;
				}
				else {
					string _params = callData[1][0 .. $-1];
					params = split(_params, ",");
					name = callData[0];
				}
			}
		}
	}
	
	AExpressionTuple expression;
	expression[0] = expData[0];
	expression[1] = expData[1];
	expression[2] = name;
	expression[3] = isCall;
	expression[4] = params;
	return expression;
}

/**
*	Enumeration of LO operators.
*/
private enum AOperators3 = [
	"++", "--"
];

/**
*	Tokenizes an expression. (leftHandOP)
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Expression tuple for the expression.
*/
auto tokenizeExpression2(string fileName, size_t lineNumber, string input) {
	AExpressionTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	errorReturn[2] = null;
	
	if (input.length < 3) {
		return errorReturn;
	}
	
	if (canFind(input, " ")) {
		return errorReturn;
	}
	
	string name = input[0 .. $-2];
	string op = input[$-2 .. $];
	if (!canFind(AOperators3, op)) {
		return errorReturn;
	}
	
	AExpressionTuple expression;
	expression[0] = name;
	expression[1] = op;
	return expression;
}

/**
*	Tokenizes an expression. (leftHand, operator, rightHand)
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Expression tuple for the expression.
*/
auto tokenizeExpression3(bool isCompare)(string fileName, size_t lineNumber, string input) {
	static if (isCompare)
		return tokenizeExpression1(fileName, lineNumber, input, AOperators2);
	else
		return tokenizeExpression1(fileName, lineNumber, input, AOperators1);
}