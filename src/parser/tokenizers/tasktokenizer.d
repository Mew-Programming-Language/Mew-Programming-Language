/*
	This module is for tokenizing tasks.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizers.tasktokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

// Tokenizer Imports
import parser.tokenizers.variabletokenizer;


//name,returnType,parameters
/**
*	Task tuple
*/
alias ATaskTuple = Tuple!(string,string,ATypeTuple[]);

/**
*	Tokenizes a task.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Task tuple for the task.
*/
auto tokenizeTask(string fileName, size_t lineNumber, string input, string[] structs, string[] classes, string[] enums) {
	ATaskTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	errorReturn[2] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid Task Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!canFind(input, ":")) {
		reportError(fileName, lineNumber, "Invalid Task Syntax", "Cannot find ':'");
		return errorReturn;
	}
	
	auto taskData = split(input, "(");
	if (taskData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Task Syntax", "Found multiple '(' when a task only allows one.");
		return errorReturn;
	}
	
	auto taskInfo = split(taskData[0], " ");
	if (taskInfo[0] != "task") {
		reportError(fileName, lineNumber, "Invalid Task Syntax", "Not a task.");
		return errorReturn;
	}
	
	string returnType;
	if (taskInfo.length == 3) {
		auto rType = tokenizeVariable(fileName, lineNumber, taskInfo[1] ~ " " ~ taskInfo[2], structs, classes, enums);
		returnType = rType[0];
	}
	else if (taskInfo.length != 2) {
		reportError(fileName, lineNumber, "Invalid Task Syntax", "Cannot parse task info.");
		return errorReturn;
	}
	
	ATypeTuple[] paramTuples;
	if (taskData[1] != ":") {
		// parameters ...
		if (!endsWith(taskData[1], ":")) {
			reportError(fileName, lineNumber, "Invalid Task Syntax", "Does not end with ':'");
			return errorReturn;
		}
		auto params = split(taskData[1][0 .. $-1], ",");
		foreach (param; params) {
			auto paramTuple = tokenizeVariable(fileName, lineNumber, param, structs, classes, enums);
			if (!paramTuple[0])
				return errorReturn; // tokenizeVariable() already reports the error
			paramTuples ~= paramTuple;
		}
	}
	else if (!endsWith(input, "(:")) { // No parameters, but invalid syntax ...
		reportError(fileName, lineNumber, "Invalid Task Syntax", "No parameters. The task has to end with '(:'");
		return errorReturn;
	}
	
	ATaskTuple returnTask;
	if (taskInfo.length == 3)
		returnTask[0] = taskInfo[2];
	else
		returnTask[0] = taskInfo[1];
	returnTask[1] = returnType;
	returnTask[2] = paramTuples;
	return returnTask;
}