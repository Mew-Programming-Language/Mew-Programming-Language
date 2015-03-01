/*
	Module for parsing Left-hand + Operator expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.exp.lo;

// Std Imports
import std.algorithm : canFind, startsWith;
import std.array : split, replace;
import std.string : format;

// Mew Imports
import errors.report;

// Type Related Imports
import parser.types.typecore;
import parser.types.moduletype;
import parser.types.structtype;
import parser.types.classtype;
import parser.types.variabletype;
import parser.types.tasktype;
import parser.types.expressions;

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
		if (names.length == 2) {
			string parentName = names[0];
			string childName = names[1];
			
			// parent -> child call
			if (parentName in task.variables) {
				auto parent = task.variables[parentName];
				if (parent) { // Safety check ...
					string parentType = replace(parent.type, "*", ""); // Strips the pointer of the type name ...
					
					if (parentType in mod.structs) {
						// The parent is a struct
						auto parentObject = mod.structs[parentType];
						if (parentObject) { // Safety check ...
							if (childName in parentObject.childVariables) {
								// The child is a variable variable
								auto childVariable = parentObject.childVariables[childName];
								if (childVariable) { // Safety check ...
									if (childVariable.modifier1 == ModifierAccess1._public) {
										// The child variable is a public member
										// Check operator + types for valid expressions
										task.addExp(new LOExpression(expression));
									}
									else {
										// The child variable cannot be accessed ...
										reportError(fileName, lineNumber, "Call Error", format("'%s.%s' is not accessible from here.", parentName, childName));
									}
								}
								else {
									// The child variable instance is null
									reportError(fileName, lineNumber, "Call Error", format("'%s.%s' has no instance within the compiler.", parentName, childName));
								}
							}
							else {
								// The child was not defined
								reportError(fileName, lineNumber, "Call Error", format("'%s.%s' was not defined.", parentName, childName));
							}
						}
						else {
							// The parent variable instance is null
							reportError(fileName, lineNumber, "Call Error", format("'%s' has no instance within the compiler.", parentName));
						}
					}
					else if (parentType in mod.classes) {
						// The parent is a class
						auto parentObject = mod.classes[parentType];
						if (parentObject) { // Safety check ...
							if (childName in parentObject.initVariables) {
								// The child is a variable variable
								auto childVariable = parentObject.initVariables[childName];
								if (childVariable) { // Safety check ...
									if (childVariable.modifier1 == ModifierAccess1._public) {
										// The child variable is a public member
										// Check operator + types for valid expressions
										task.addExp(new LOExpression(expression));
									}
									else {
										// The child variable cannot be accessed ...
										reportError(fileName, lineNumber, "Call Error", format("'%s.%s' is not accessible from here.", parentName, childName));
									}
								}
								else {
									// The child variable instance is null
									reportError(fileName, lineNumber, "Call Error", format("'%s.%s' has no instance within the compiler.", parentName, childName));
								}
							}
							else {
								// The child was not defined
								reportError(fileName, lineNumber, "Call Error", format("'%s.%s' was not defined.", parentName, childName));
							}
						}
						else {
							// The parent variable instance is null
							reportError(fileName, lineNumber, "Call Error", format("'%s' has no instance within the compiler.", parentName));
						}
					}
					else {
						// The parent type is not a parental type
						reportError(fileName, lineNumber, "Call Error", format("'%s' is not struct or class.", parentName));
					}
				}
				else {
					// The parent instance is null
					reportError(fileName, lineNumber, "Call Error", format("'%s' has no instance within the compiler.", parentName));
				}
			}
			else {
				// The parent was not defined
				reportError(fileName, lineNumber, "Call Error", format("'%s' was not defined", parentName));
			}
		}
		else {
			// local- or imported variable
			string varName = names[0];
			if (varName in task.variables) {
				// The variable exists
				auto var = task.variables[varName];
				if (var) { // Safety check ...
					task.addExp(new LOExpression(expression));
				}
				else {
					// The variable instance is null
					reportError(fileName, lineNumber, "Call Error", format("'%s' has no instance within the compiler.", varName));
				}
			}
			else {
				// The variable was not defined
				// TODO: Implement value references ...
				reportError(fileName, lineNumber, "Call Error", format("'%s' was not defined.", varName));
			}
		}
	}
}