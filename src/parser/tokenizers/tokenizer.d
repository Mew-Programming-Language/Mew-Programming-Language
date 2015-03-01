/*
	This module is for tokenizing types and expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.tokenizercore;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer imports
public import parser.tokenizers.variabletokenizer;
public import parser.tokenizers.tasktokenizer;
public import parser.tokenizers.structtokenizer;
public import parser.tokenizers.classtokenizer;
public import parser.tokenizers.expressiontokenizer;
public import parser.tokenizers.returntokenizer;