/*
	Module for parsing Left-hand + Operator + Right-hand expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.exp.lor;

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
*	Expression evaluation types.
*/
private enum ExpEvaluation {
	validateLeftHand,
	addVariableExpression,
	addCallExpression,
	addIfExpression
}

private Variable handleExpression(ExpEvaluation eva)(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod, string exp, bool isElif = false, Variable leftVar = null, string[] params = null) {
	string[] names = split(exp, ".");
	if (!names)
		names = [exp];
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
							static if (eva == ExpEvaluation.addCallExpression) {
								auto childCollection = parentObject.initTasks;
							}
							else {
								auto childCollection = parentObject.childVariables;
							}
							
							if (childName in childCollection) {
								// The child is a variable variable
								auto child = childCollection[childName];
								if (child) { // Safety check ...
									if (child.modifier1 == ModifierAccess1._public) {
										// The child variable is a public member
										// Check operator + types for valid expressions
										static if (eva == ExpEvaluation.addVariableExpression) {
											task.addExp(new LORExpression(expression));
											return child;
										}
										else static if (eva == ExpEvaluation.addCallExpression) {
											if (!child.parameters && params) {
												reportError(fileName, lineNumber, "Call Error", format("Invalid parameters for '%s.%s'", parentName, childName));
											}
											else {
												string[] nparams;
												if (params) {
													// There are parameters
													foreach (i; 0 .. params.length) {
														// Loop through passed parameters ...
														auto param = params[i];
														if (param !in task.variables) {
															// The parameter passed is not an accessible variable
															reportError(fileName, lineNumber, "Call Error", format("'%s' could not be passed as a parameter.", param));
															return null;
														}

														// Gets the passed parameter and the parameter to set
														auto varPass = task.variables[param];
														if (!varPass) { // Safety check
															reportError(fileName, lineNumber, "Call Error", format("'%s' has no compiler instance.", param));
															return null;
														}
														// The index makes sure the passed parameter matches the correct parameter
														auto varParam = child.parameters[i];
														if (!varParam) { // Safety check
															reportError(fileName, lineNumber, "Call Error", format("The matching parameter of '%s' has no compiler instance.", param));
															return null;
														}
														
														if (varPass.type != varParam.type) {
															// The variables doesn't have the same type
															// Proceed to cast
															// TODO: Check types for casting, if valid
															nparams ~= format("(%s)%s", varParam.type, param);
														}
														else {
															// The variables have the same type
															// Pass it normally
															nparams ~= param;
														}
													}
												}
												nparams = [parentName] ~ nparams;
												
												// else no parameters
												if (!child.returnType || child.returnType == "void") {
													reportError(fileName, lineNumber, "Invalid Call Type", format("'%s.%s' is of type void and has no return value.", parentName, childName));
													return null;
												}
												
												if (leftVar.type != child.returnType) {
													// The variable doesn't have the same type as the task's return type
													// Proceed to cast
													
													// Replaces the . with _ since functions are located outside of the parent
													// Also replaces the instance name with the parent name
													string callExp = replace(expression[2], parentName ~ ".", parentObject.name ~ "_");
													
													expression[2] = format("(%s)%s", leftVar.type, callExp);
													task.addExp(new LORCallExpression(expression, nparams));
												}
												else {
													// Replaces the . with _ since functions are located outside of the parent
													// Also replaces the instance name with the parent name
													string callExp = replace(expression[2], parentName ~ ".", parentObject.name ~ "_");
													expression[2] = callExp;
													
													task.addExp(new LORCallExpression(expression, nparams));
												}
											}
											return leftVar;
										}
										else static if (eva == ExpEvaluation.addIfExpression) {
											if (isElif)
												task.addExp(new IfExpression(["else if"] ~ expression));
											else
												task.addExp(new IfExpression(["if"] ~ expression));
											return child;
										}
										else
											return child;
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
							static if (eva == ExpEvaluation.addCallExpression) {
								auto childCollection = parentObject.initTasks;
							}
							else {
								auto childCollection = parentObject.initVariables;
							}
							
							if (childName in childCollection) {
								// The child is a variable variable
								auto child = childCollection[childName];
								if (child) { // Safety check ...
									if (child.modifier1 == ModifierAccess1._public) {
										// The child variable is a public member
										// Check operator + types for valid expressions
										static if (eva == ExpEvaluation.addVariableExpression) {
											task.addExp(new LORExpression(expression));
											return child;
										}
										else static if (eva == ExpEvaluation.addCallExpression) {
											if (!child.parameters && params) {
												reportError(fileName, lineNumber, "Call Error", format("Invalid parameters for '%s.%s'", parentName, childName));
											}
											else {
												string[] nparams;
												if (params) {
													// There are parameters
													foreach (i; 0 .. params.length) {
														// Loop through passed parameters ...
														auto param = params[i];
														if (param !in task.variables) {
															// The parameter passed is not an accessible variable
															reportError(fileName, lineNumber, "Call Error", format("'%s' could not be passed as a parameter.", param));
															return null;
														}

														// Gets the passed parameter and the parameter to set
														auto varPass = task.variables[param];
														if (!varPass) { // Safety check
															reportError(fileName, lineNumber, "Call Error", format("'%s' has no compiler instance.", param));
															return null;
														}
														// The index makes sure the passed parameter matches the correct parameter
														auto varParam = child.parameters[i];
														if (!varParam) { // Safety check
															reportError(fileName, lineNumber, "Call Error", format("The matching parameter of '%s' has no compiler instance.", param));
															return null;
														}
														
														if (varPass.type != varParam.type) {
															// The variables doesn't have the same type
															// Proceed to cast
															// TODO: Check types for casting, if valid
															nparams ~= format("(%s)%s", varParam.type, param);
														}
														else {
															// The variables have the same type
															// Pass it normally
															nparams ~= param;
														}
													}
												}
												nparams = [parentName] ~ nparams;
												
												// else no parameters
												if (!child.returnType || child.returnType == "void") {
													reportError(fileName, lineNumber, "Invalid Call Type", format("'%s.%s' is of type void and has no return value.", parentName, childName));
													return null;
												}
												
												if (leftVar.type != child.returnType) {
													// The variable doesn't have the same type as the task's return type
													// Proceed to cast
													
													// Replaces the . with _ since functions are located outside of the parent
													// Also replaces the instance name with the parent name
													string callExp = replace(expression[2], parentName ~ ".", parentObject.name ~ "_");
								
													expression[2] = format("(%s)%s", leftVar.type, callExp);
													task.addExp(new LORCallExpression(expression, nparams));
												}
												else {
													// Replaces the . with _ since functions are located outside of the parent
													// Also replaces the instance name with the parent name
													string callExp = replace(expression[2], parentName ~ ".", parentObject.name ~ "_");
													
													task.addExp(new LORCallExpression(expression, nparams));
												}
											}
											return leftVar;
										}
										else static if (eva == ExpEvaluation.addIfExpression) {
											if (isElif)
												task.addExp(new IfExpression(["else if"] ~ expression));
											else
												task.addExp(new IfExpression(["if"] ~ expression));
											return child;
										}
										else
											return child;
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
			// local- or imported variable / task
			string memberName = names[0];
			static if (eva == ExpEvaluation.addCallExpression) {
				auto collection = task.tasks;
			}
			else {
				auto collection = task.variables;
			}
							
			if (memberName in collection) {
				// The variable / task exists
				auto member = collection[memberName];
				if (member) { // Safety check ...
					static if (eva == ExpEvaluation.addVariableExpression) {
						// Evaluating local parent members
						if (task.parent) {
							auto parent = task.parent;
							if (parent.name in mod.structs) {
								// The parent is a struct
								auto parentObject = mod.structs[parent.name];
								
								if (leftVar.name in parentObject.childVariables &&
									leftVar.name !in task.initVariables) {
									// The left variable is parent local and not task local
									// Changes it to call the instance of the parent
									expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
								}
								
								if (member.name in parentObject.childVariables &&
									member.name !in task.initVariables) {
									// The right member is parent local and not task local
									expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
								}
							}
							else if (parent.name in mod.classes) {
								// The parent is a struct
								auto parentObject = mod.classes[parent.name];
								
								if (leftVar.name in parentObject.initVariables &&
									leftVar.name !in task.initVariables) {
									// The left variable is parent local and not task local
									// Changes it to call the instance of the parent
									expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
								}
								
								if (member.name in parentObject.initVariables &&
									member.name !in task.initVariables) {
									// The right member is parent local and not task local
									expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
								}
							}
						}
		
						task.addExp(new LORExpression(expression));
						return member;
					}
					else static if (eva == ExpEvaluation.addCallExpression) {
						if (!member.parameters && params) {
							reportError(fileName, lineNumber, "Call Error", format("Invalid parameters for '%s'", memberName));
						}
						else {
							string[] nparams;
							if (params) {
								// There are parameters
								foreach (i; 0 .. params.length) {
									// Loop through passed parameters ...
									auto param = params[i];
									if (param !in task.variables) {
										// The parameter passed is not an accessible variable
										reportError(fileName, lineNumber, "Call Error", format("'%s' could not be passed as a parameter.", param));
										return null;
									}
									// Gets the passed parameter and the parameter to set
									auto varPass = task.variables[param];
									if (!varPass) { // Safety check
										reportError(fileName, lineNumber, "Call Error", format("'%s' has no compiler instance.", param));
										return null;
									}
									// The index makes sure the passed parameter matches the correct parameter
									auto varParam = member.parameters[i];
									if (!varParam) { // Safety check
										reportError(fileName, lineNumber, "Call Error", format("The matching parameter of '%s' has no compiler instance.", param));
										return null;
									}
												
									if (varPass.type != varParam.type) {
										// The variables doesn't have the same type
										// Proceed to cast
										// TODO: Check types for casting, if valid
										nparams ~= format("(%s)%s", varParam.type, param);
									}
									else {
										// The variables have the same type
										// Pass it normally
										nparams ~= param;
									}
								}
							}
							// else no parameters
							if (!member.returnType || member.returnType == "void") {
								reportError(fileName, lineNumber, "Invalid Call Type", format("'%s' is of type void and has no return value.", memberName));
								return null;
							}
							
							// Evaluating local parent members
							if (task.parent) {
								auto parent = task.parent;
								if (parent.name in mod.structs) {
									// The parent is a struct
									auto parentObject = mod.structs[parent.name];
								
									if (leftVar.name in parentObject.childVariables &&
										leftVar.name !in task.initVariables) {
										// The left variable is parent local and not task local
										// Changes it to call the instance of the parent
										expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
									}
								
									if (member.name in parentObject.childVariables &&
										member.name !in task.initVariables) {
										// The right member is parent local and not task local
										expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
									}
								}
								else if (parent.name in mod.classes) {
									// The parent is a struct
									auto parentObject = mod.classes[parent.name];
								
									if (leftVar.name in parentObject.initVariables &&
										leftVar.name !in task.initVariables) {
										// The left variable is parent local and not task local
										// Changes it to call the instance of the parent
										expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
									}
								
									if (member.name in parentObject.initVariables &&
										member.name !in task.initVariables) {
										// The right member is parent local and not task local
										expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
									}
								}
							}
						
							string callExp = expression[2];
							if (member.parent) {
								// Gets the parent name and corrects the task name
								callExp = replace(callExp, memberName, member.parent.name ~ "_" ~ memberName);
							}
							
							if (leftVar.type != member.returnType) {
								// The variable doesn't have the same type as the task's return type
								// Proceed to cast
								expression[2] = format("(%s)%s", leftVar.type, callExp);
								task.addExp(new LORCallExpression(expression, nparams));
							}
							else {
								expression[2] = callExp;
								task.addExp(new LORCallExpression(expression, nparams));
							}
						}
						return leftVar;
					}
					else static if (eva == ExpEvaluation.addIfExpression) {
						// Evaluating local parent members
						if (task.parent) {
							auto parent = task.parent;
							if (parent.name in mod.structs) {
								// The parent is a struct
								auto parentObject = mod.structs[parent.name];
								
								if (leftVar.name in parentObject.childVariables &&
									leftVar.name !in task.initVariables) {
									// The left variable is parent local and not task local
									// Changes it to call the instance of the parent
									expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
								}
								
								if (member.name in parentObject.childVariables &&
									member.name !in task.initVariables) {
									// The right member is parent local and not task local
									expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
								}
							}
							else if (parent.name in mod.classes) {
								// The parent is a struct
								auto parentObject = mod.classes[parent.name];
								
								if (leftVar.name in parentObject.initVariables &&
									leftVar.name !in task.initVariables) {
									// The left variable is parent local and not task local
									// Changes it to call the instance of the parent
									expression[0] = replace(expression[0], leftVar.name, "this->" ~ leftVar.name);
								}
								
								if (member.name in parentObject.initVariables &&
									member.name !in task.initVariables) {
									// The right member is parent local and not task local
									expression[2] = replace(expression[2], member.name, "this->" ~ member.name);
								}
							}
						}
						
						if (isElif)
							task.addExp(new IfExpression(["else if"] ~ expression));
						else
							task.addExp(new IfExpression(["if"] ~ expression));
						return member;
					}
					else
						return member;
				}
				else {
					// The variable / task instance is null
					reportError(fileName, lineNumber, "Call Error", format("'%s' has no instance within the compiler.", memberName));
				}
			}
			else {
				// The variable / task was not defined
				// TODO: Implement value references ...
				reportError(fileName, lineNumber, "Call Error", format("'%s' was not defined.", memberName));
			}
		}
	}
	return null;
}

/**
*	Handles a LOR variable expression and validates expression names.
*	Params:
*		task =			The task with the expression.
*		fileName =		The name of the file.
*		lineNumber =	(ref) The current line.
*		expression =	The expression to handle.
*		mod =			The module.
*/
auto handleLORVariableExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod) {
	Variable leftVar = handleExpression!(ExpEvaluation.validateLeftHand)(task, fileName, lineNumber, expression, mod, expression[0]);
	if (!leftVar)
		return leftVar; // Returns null ...
	return handleExpression!(ExpEvaluation.addVariableExpression)(task, fileName, lineNumber, expression, mod, expression[2], false, leftVar);
}

/**
*	Handles a LOR call expression and validates expression names.
*	Params:
*		task =			The task with the expression.
*		fileName =		The name of the file.
*		lineNumber =	(ref) The current line.
*		expression =	The expression to handle.
*		params =		The parameters
*		mod =			The module.
*/
void handleLORCallExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, string[] params, Module mod) {
	auto leftVar = handleExpression!(ExpEvaluation.validateLeftHand)(task, fileName, lineNumber, expression, mod, expression[0]);
	if (!leftVar) {
		reportError(fileName, lineNumber, "Call Error", "Invalid left hand.");
		return;
	}
	handleExpression!(ExpEvaluation.addCallExpression)(task, fileName, lineNumber, expression, mod, expression[2], false, leftVar, params);
}

/**
*	Handles a LOR compare expression and validates expression names.
*	Params:
*		task =			The task with the expression.
*		fileName =		The name of the file.
*		lineNumber =	(ref) The current line.
*		expression =	The expression to handle.
*		mod =			The module.
*/
auto handleLORCompareExpression(Task task, string fileName, ref size_t lineNumber, string[] expression, Module mod, bool isElif) {
	Variable leftVar = handleExpression!(ExpEvaluation.validateLeftHand)(task, fileName, lineNumber, expression, mod, expression[0]);
	if (!leftVar) {
		return leftVar; // Returns null ...
	}
	return handleExpression!(ExpEvaluation.addIfExpression)(task, fileName, lineNumber, expression, mod, expression[2], isElif, leftVar);
}