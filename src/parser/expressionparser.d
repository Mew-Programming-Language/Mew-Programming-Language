/*
	This module is for expression parsing.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.expressionparser;

// Std Imports
import std.algorithm : canFind, startsWith;
import std.array : split, replace;
import std.string : format;

// Mew Imports
import errors.report;

// Expression Related Imports
public import parser.exp.lo; // Left-hand + Operator Expression
public import parser.exp.lor; // Left-hand + Operator + Right-hand Expression