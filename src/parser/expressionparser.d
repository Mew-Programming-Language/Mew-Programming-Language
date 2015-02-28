/*
	This module is for name validation for types.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.expressionparser;

// Std Imports
import std.algorithm : canFind, startsWith;
import std.array : split;
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
		if (names[0] in task.variables) {
			if (names.length == 2) {
				auto parent = task.variables[names[0]];
				if (parent) {
					if (parent.type in mod.structs) {
						auto parentType = mod.structs[parent.type];
						if (names[1] in parentType.childVariables) {
							auto var = parentType.childVariables[names[1]];
							if (var.modifier1 == ModifierAccess1._public) {
								// check operator + type ...
								task.addExp(new LOExpression(expression));
							}
							else
								reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
						}
						else
							reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
					}
					else if (parent.type in mod.classes) {
						auto parentType = mod.classes[parent.type];
						if (names[1] in parentType.initVariables) {
							auto var = parentType.initVariables[names[1]];
							if (var.modifier1 == ModifierAccess1._public) {
								// check operator + type
								task.addExp(new LOExpression(expression));
							}
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
auto handleLORExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod, bool checkRight = true) {
	// LEFT
	Variable leftVar;
	{
		string expName = expression[0];
		string[] names = split(expName, ".");
		if (!names)
			names = [expName];
		if (names.length > 2) {
			reportError(fileName, lineNumber, "Call Error", "The call is too nested.");
		}
		else {
			if (names[0] in task.variables) {
				if (names.length == 2) {
					auto parent = task.variables[names[0]];
					if (parent) {
						if (parent.type in mod.structs) {
							auto parentType = mod.structs[parent.type];
							if (names[1] in parentType.childVariables) {
								auto var = parentType.childVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									leftVar = var;
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
						}
						else if (parent.type in mod.classes) {
							auto parentType = mod.classes[parent.type];
							if (names[1] in parentType.initVariables) {
								auto var = parentType.initVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public)
									leftVar = var;
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
					leftVar = task.variables[names[0]];
				}
			}
			else
				reportError(fileName, lineNumber, "Invalid Definition", format("'%s' is not defined.", expName));
		}
	}
	
	if (!leftVar)
		return leftVar;
	if (!checkRight)
		return leftVar;
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
			if (names[0] in task.variables) {
				if (names.length == 2) {
					auto parent = task.variables[names[0]];
					if (parent) {
						if (parent.type in mod.structs) {
							auto parentType = mod.structs[parent.type];
							if (names[1] in parentType.childVariables) {
								auto var = parentType.childVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public) {
									if (leftVar.type != var.type) {
										expression[2] = format("(%s)%s", leftVar.type, expression[2]);
										task.addExp(new LORExpression(expression));
									}
									else
										task.addExp(new LORExpression(expression));
								}
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Invalid Member", format("'%s' is not a member of '%s'", names[1], parent.name));
						}
						else if (parent.type in mod.classes) {
							auto parentType = mod.classes[parent.type];
							if (names[1] in parentType.initVariables) {
								auto var = parentType.initVariables[names[1]];
								if (var.modifier1 == ModifierAccess1._public) {
									if (leftVar.type != var.type) {
										expression[2] = format("(%s)%s", leftVar.type, expression[2]);
										task.addExp(new LORExpression(expression));
									}
									else
										task.addExp(new LORExpression(expression));
								}
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
	return leftVar;
}

void handleLORCall(Task task, string fileName, ref size_t lineNumber, string[] expression, string[] params, Module mod) {
	auto leftVar = handleLORExpression(task, fileName, lineNumber, expression, mod, false);
	if (leftVar) {
		// Check right hand ...
		string expName = expression[2];
		string[] names = split(expName, ".");
		if (!names)
			names = [expName];
		if (names.length > 2) {
			reportError(fileName, lineNumber, "Call Error", "The call is too nested.");
		}
		else {
			if (names[0] in task.variables) {
				if (names.length == 2) {
					auto parent = task.variables[names[0]];
					if (parent) {
						if (parent.type in mod.structs) {
							auto parentType = mod.structs[parent.type];
							if (names[1] in parentType.tasks) {
								auto call = parentType.tasks[names[1]];
								if (call.modifier1 == ModifierAccess1._public) {
									if ((call.parameters && !params) ||
										(!call.parameters && params) ||
										call.parameters.length != params.length) {
										reportError(fileName, lineNumber, "Call Error", format("'%s' was called with invalid parameter count", names[1]));
									}
									else {
										string[] nparams;
										if (params) {
											foreach (i; 0 .. params.length) {
												auto param = params[i];
												if (param !in task.variables) {
													reportError(fileName, lineNumber, "Call Error", format("'%s' could not be passed as a parameter.", param));
													return;
												}
											
												auto varPass = task.variables[param];
												auto varParam = call.parameters[i];
											
												if (varPass.type != varParam.type) {
													nparams ~= format("(%s)%s", varParam.type, param);
												}
												else
													nparams ~= param;
											}
										}
										
										if (!call.returnType) {
											reportError(fileName, lineNumber, "Invalid Call Type", format("'%s.%s' is of type void and has no return value.", names[0], names[1]));
											return;
										}
										
										if (leftVar.type != call.returnType) {
											expression[2] = format("(%s)%s", leftVar.type, expression[2]);
											task.addExp(new LORCallExpression(expression, nparams));
										}
										else
											task.addExp(new LORCallExpression(expression, nparams));
									}
								}
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Call Error", format("'%s' was not found in '%s'.", names[0], parentType.name));
						}
						else if (parent.type in mod.classes) {
							auto parentType = mod.classes[parent.type];
							if (names[1] in parentType.tasks) {
								auto call = parentType.tasks[names[1]];
								if (call.modifier1 == ModifierAccess1._public) {
									if ((call.parameters && !params) ||
										(!call.parameters && params) ||
										call.parameters.length != params.length) {
										reportError(fileName, lineNumber, "Call Error", format("'%s' was called with invalid parameter count", names[1]));
									}
									else {
										string[] nparams;
										if (params) {
											foreach (i; 0 .. params.length) {
												auto param = params[i];
												if (param !in task.variables) {
													reportError(fileName, lineNumber, "Call Error", format("'%s' could not be passed as a parameter.", param));
													return;
												}
											
												auto varPass = task.variables[param];
												auto varParam = call.parameters[i];
											
												if (varPass.type != varParam.type) {
													nparams ~= format("(%s)%s", varParam.type, param);
												}
												else
													nparams ~= param;
											}
										}
										
										if (!call.returnType) {
											reportError(fileName, lineNumber, "Invalid Call Type", format("'%s.%s' is of type void and has no return value.", names[0], names[1]));
											return;
										}
										
										if (leftVar.type != call.returnType) {
											expression[2] = format("(%s)%s", leftVar.type, expression[2]);
											task.addExp(new LORCallExpression(expression, nparams));
										}
										else
											task.addExp(new LORCallExpression(expression, nparams));
									}
								}
								else
									reportError(fileName, lineNumber, "Invalid Accessibility", format("'%s.%s' is not accessible from here.", names[0], names[1]));
							}
							else
								reportError(fileName, lineNumber, "Call Error", format("'%s' was not found in '%s'.", names[0], parentType.name));
						}
					}
				}
				else {
					reportError(fileName, lineNumber, "Call Error", format("'%s' is a variable and not a task.", names[0]));
				}
			}
			else if (names[0] in mod.globalVariables) {
				// check ...
				reportError(fileName, lineNumber, "Call Error", "GLOBAL."); // TODO: Implement gloal calls ...
			}
		}
	}
	else {
		// The left hand variable was invalid ...
		reportError(fileName, lineNumber, "Call Error", "Invalid left hand.");
	}
}