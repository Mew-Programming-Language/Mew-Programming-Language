/*
	This module is for name validation for types.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.namevalidator;

// Std Imports
import std.algorithm : canFind, startsWith;
import std.array : split;
import std.string : format;

// Mew Imports
import errors.report;
import parser.parsingtypes;

/**
*	Validates a type name.
*	Params:
*		name =		The name to validate.
*		ignore =	Boolean determining whether it should ignore type-name conflicts.
*	Returns: True if the name is valid, false otherwise.
*/
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

/**
*	Enumeration for datatypes.
*/
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

/**
*	Checks whether an input string is a datatype.
*	Params:
*		S =	The input string.
*	Returns: True if the input string is a datatype.
*/
private bool isDataType(string S) {
	return canFind(DTs, S);
}

/**
*	Checks whether an input string is A-Z, 0-9 and "_"
*	Params:
*		S = The input string.
*	Returns: True if the input string is valid.
*/
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

/**
*	Handles a LO expression and validates expression names.
*	Params:
*		task =			The task with the expression.
*		fileName =		The name of the file.
*		lineNumber =	(ref) The current line.
*		expression =	The expression to handle.
*		mod =			The module.
*/
void handleLOExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod) {
	string[] names = split(expression[0], ".");
	if (!names)
		names = [expression[0]];
	if (names.length > 2) {
		reportError(fileName, lineNumber, "Call Error", "The call is too nested.");
	}
	else {
		if (names[0] in task.initVariables) {
			if (names.length == 2) {
				auto parent = task.initVariables[names[0]];
				if (parent) {
					if (parent.udt in mod.structs) {
						auto parentType = mod.structs[parent.udt];
						if (names[1] in parentType.childVariables) {
							auto var = parentType.childVariables[names[1]];
							if (var.modifier1 == ModifierAccess1._public)
								task.addExp(new LOExpression(expression));
							else
								reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
						}
						else
							reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
					}
					else if (parent.udt in mod.classes) {
						auto parentType = mod.classes[parent.udt];
						if (names[1] in parentType.initVariables) {
							auto var = parentType.initVariables[names[1]];
							if (var.modifier1 == ModifierAccess1._public)
								task.addExp(new LOExpression(expression));
							else
								reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
						}
						else
							reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
						}
					else {
						reportError(fileName, lineNumber, "Call Error", "Cannot call a child of a non-parental type.");
					}
				}
				else {
					reportError(fileName, lineNumber, "Call Error", "No parent found.");
				}
			}
			else {
				// local
				task.addExp(new LOExpression(expression));
			}
		}
		else
			reportError(fileName, lineNumber, "Invalid Definition", format("'%s' is not defined.", expression[0]));
	}
}

/**
*	Handles a LOR expression and validates expression names.
*	Params:
*		task =			The task with the expression.
*		fileName =		The name of the file.
*		lineNumber =	(ref) The current line.
*		expression =	The expression to handle.
*		mod =			The module.
*/
void handleLORExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod) {
	bool leftMatch = false;
	// LEFT
	{
		string expName = expression[0];
		string[] names = split(expName, ".");
		if (!names)
			names = [expName];
		if (names.length > 2) {
			reportError(fileName, lineNumber, "Call Error", "The call is too nested.");
		}
		else {
			if (names[0] in task.initVariables) {
				if (names.length == 2) {
					auto parent = task.initVariables[names[0]];
					if (parent) {
						if (parent.udt in mod.structs) {
							auto parentType = mod.structs[parent.udt];
							if (names[1] in parentType.childVariables) {
								auto var = parentType.childVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									leftMatch = true;
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
						}
						else if (parent.udt in mod.classes) {
							auto parentType = mod.classes[parent.udt];
							if (names[1] in parentType.initVariables) {
								auto var = parentType.initVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									leftMatch = true;
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
							}
						else {
							reportError(fileName, lineNumber, "Call Error", "Cannot call a child of a non-parental type.");
						}
					}
					else { 
						reportError(fileName, lineNumber, "Call Error", "No parent found.");
					}
				}
				else {
					// local
					leftMatch = true;
				}
			}
			else
				reportError(fileName, lineNumber, "Invalid Definition", format("'%s' is not defined.", expName));
		}
	}
	
	if (!leftMatch)
		return;
	
	// RIGHT
	{
		string expName = expression[2];
		string[] names = split(expName, ".");
		if (!names)
			names = [expName];
		if (names.length > 2) {
			reportError(fileName, lineNumber, "Call Error", "The call is too nested.");
		}
		else {
			if (names[0] in task.initVariables) {
				if (names.length == 2) {
					auto parent = task.initVariables[names[0]];
					if (parent) {
						if (parent.udt in mod.structs) {
							auto parentType = mod.structs[parent.udt];
							if (names[1] in parentType.childVariables) {
								auto var = parentType.childVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									task.addExp(new LORExpression(expression));
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
						}
						else if (parent.udt in mod.classes) {
							auto parentType = mod.classes[parent.udt];
							if (names[1] in parentType.initVariables) {
								auto var = parentType.initVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									task.addExp(new LORExpression(expression));
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
							}
						else {
							reportError(fileName, lineNumber, "Call Error", "Cannot call a child of a non-parental type.");
						}
					}
					else {
						reportError(fileName, lineNumber, "Call Error", "No parent found.");
					}
				}
				else {
					// local
					task.addExp(new LORExpression(expression));
				}
			}
			else
				reportError(fileName, lineNumber, "Invalid Definition", format("'%s' is not defined.", expName));
		}
	}
}