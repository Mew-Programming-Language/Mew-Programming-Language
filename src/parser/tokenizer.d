/*
	This module is for tokenizing types and expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

/**
*	Enumeration for c data types.
*/
enum ADataTypes = [
	"byte" : "char",
	"short" : "short",
	"int" : "int",
	"long" : "long",
	"ubyte" : "unsigned char",
	"ushort" : "unsigned short",
	"uint" : "unsigned int",
	"ulong" : "unsigned long",
	"float" : "float",
	"double" : "double",
	"float" : "long double",
	"bool" : "bool",
	"char" : "char",
	"string" : "Array_string"
];

/**
*	Enumeration for ADT's
*/
private enum AbstractDataTypes = [
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
*	The type of single data types.
*/
private enum ADataSingleType {
	pod,
	_struct,
	_class,
	_enum
}

//type,name,defaultValue
/**
*	Type tuple.
*/
alias ATypeTuple = Tuple!(string,string,string);

/**
*	Checks whether an input is numeric or not.
*	This makes use isNumeric from std.string.
*	Params:
*		input =		The input to validate.
*		isFloat =	Boolean determining whether a float point value is valid or not.
*	Returns: True if the input was numeric, false otherwise.
*/
private bool isNumericValue(string input, bool isFloat) {
	string valid = "";
	if (!isFloat && canFind(input, ".")) {
		return false;
	}
	import std.string : isNumeric;
	return isNumeric(input);
}

/**
*	Sets the c type by a string reference.
*	Params:
*		type =		The type reference string.
*		setType =	The type to set.
*	Returns: True if the datatype was set.
*/
private bool setType(string type, ref string setType) {
	import csettings;
	if (type in ADataTypes) {
		setType = ADataTypes[type];
		return true;
	}
	else if (type == "size_t") {
		if (outputFormat == OSFormat.x86)
			setType = ADataTypes["uint"];
		else
			setType = ADataTypes["ulong"];
		return true;
	}
	else if (type == "ptrdiff_t") {
		if (outputFormat == OSFormat.x86)
			setType = ADataTypes["int"];
		else
			setType = ADataTypes["long"];
		return true;
	}
	else
		return false;
}

/**
*	Tokenizes a variable.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Type tuple for the variable.
*/
auto tokenizeVariable(string fileName, size_t lineNumber, string input, string[] structs, string[] classes, string[] enums) {
	ATypeTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	errorReturn[2] = null;
	
	if (!input) {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "No input source.");
		return errorReturn;
	}
	
	if (!canFind(input, " ")) {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "No spaces found.");
		return errorReturn;
	}
	auto data = split(input, " ");
	if (data.length >= 3 && data[2] != "=") {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "No '=' found.");
		return errorReturn;
	}
	if (data.length != 2 && data.length <= 3) {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot parse variable.");
		return errorReturn;
	}
	
	string type;
	string dataType;
	ADataSingleType dataSingleType = ADataSingleType.pod;
	bool isADT = false;
	string setAdt;
	foreach (adt; AbstractDataTypes) {
		if (startsWith(data[0], adt)) {
			if (data.length != 2) { // not allowing adts to have values ...
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Non-parsable ADT syntax.");
				return errorReturn;
			}
		
			string arrayType = data[0][adt.length .. $];
			
			if (!startsWith(arrayType, "<") &&
				!endsWith(arrayType, ">")) {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "ADT does not start with '<' and ends with '>'");
				return errorReturn;
			}
			type = arrayType[1 .. $-1];
			
			switch (adt) {
				case "array":
					setAdt = "Array";
					goto case "sadt";
				case "list":
					setAdt = "List";
					goto case "sadt";
				case "orderlist":
					setAdt = "OrderList";
					goto case "sadt";
				case "linklist":
					setAdt = "LinkList";
					goto case "sadt";
				case "stack":
					setAdt = "Stack";
					goto case "sadt";
				case "queue":
					setAdt = "Queue";
					goto case "sadt";
				case "sadt": {
					if (!setAdt)
						goto default;
					dataType = setAdt ~ "_" ~ type;
					if (canFind(arrayType, ":")) {
						reportError(fileName, lineNumber, "Invalid Variable Syntax", "Found ':' ... ':' is only avaiable for multi-type ADT's");
						return errorReturn;
					}
					break;
				}
				
				
				case "map":
					setAdt = "Map";
					goto case "dadt";
				case "ordermap":
					setAdt = "OrderMap";
					goto case "dadt";
				case "dadt": {
					if (!setAdt)
						goto default;
					if (!canFind(arrayType, ":")) {
						reportError(fileName, lineNumber, "Invalid Variable Syntax", "Couldn't find ':' which is essential for multi-type ADT's.");
						return errorReturn;
					}
					break;
				}
				
				default: {
					reportError(fileName, lineNumber, "Invalid Variable Syntax", "Unknown ADT.");
					return errorReturn;
				}
			}
			
			isADT = true;
			break;
		}
	}
	
	if (!isADT) {
		type = data[0];
	}
	
	if (canFind(type, ":")) {
		auto types = split(type, ":");
		if (types.length != 2) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "More than one ':' found.");
			return errorReturn;
		}
		
		if (canFind(structs, types[0]) ||
			canFind(classes, types[0])) {
			dataType = types[0] ~ "*";
		}
		else if (canFind(enums, types[0])) {
			dataType = types[0];
		}
		else if (!setType(types[0], dataType)) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set first variable type.");
			return errorReturn;
		}
		
		string dataType2;
		if (canFind(structs, types[1]) ||
			canFind(classes, types[1])) {
			dataType2 = types[1] ~ "*";
		}
		else if (canFind(enums, types[1])) {
			dataType2 = types[1];
		}
		else if (!setType(types[1], dataType2)) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set secondary variable type.");
			return errorReturn;
		}
		dataType = setAdt ~ "_" ~ dataType ~ "_" ~ dataType2;
	}
	else if (canFind(structs, type) ||
		canFind(classes, type)) {
		dataType = type ~ "*";
	}
	else if (canFind(enums, type)) {
		dataType = type;
	}
	else if (!setType(type, dataType)) {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set variable type.");
		return errorReturn;
	}
	
	if (data.length == 2) {
		ATypeTuple tupleReturn;
		tupleReturn[0] = dataType;
		tupleReturn[1] = data[1]; // name ...
		tupleReturn[2] = null;
		return tupleReturn;
	}
	else if (dataSingleType != ADataSingleType.pod) {
		// structs, classes and enums can't have values atm.
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot assign value to this type.");
		return errorReturn;
	}
	else {
		int valueIndex = countUntil(input, "=");
		if (valueIndex >= (input.length - 2)) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Invalid value index.");
			return errorReturn;
		}
		
		string valueSelect = input[valueIndex + 2 .. $];
		if (type == "char") {
			if (!startsWith(valueSelect, "'") ||
				!endsWith(valueSelect, "'") ||
				valueSelect.length != 3) {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not parse char value.");
				return errorReturn;
			}
			valueSelect = to!string(valueSelect[1]);
		}
		else if (type == "string") {
			if (!startsWith(valueSelect, "\"") ||
			!endsWith(valueSelect, "\"")) {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not parse string value.");
				return errorReturn;
			}
			valueSelect = valueSelect[1 .. $-1];
		}
		else if (type == "bool") {
			if (valueSelect != "true" &&
				valueSelect != "false") {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot parse boolean value.");
				return errorReturn;
			}
		}
		else if (!isNumericValue(valueSelect, (type == "float" || type == "double" || type == "real"))) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot parse numeric value.");
			return errorReturn;
		}
		
		ATypeTuple tupleReturn;
		tupleReturn[0] = dataType;
		tupleReturn[1] = data[1]; // name ...
		tupleReturn[2] = valueSelect;
		return tupleReturn;
	}
}

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

// name
/**
*	Struct tuple
*/
alias AStructTuple = Tuple!(string);

/**
*	Tokenizes a struct.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Struct tuple for the struct.
*/
auto tokenizeStruct(string fileName, size_t lineNumber, string input) {
	AStructTuple errorReturn;
	errorReturn[0] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!endsWith(input, "(:")) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Does not end with '(:'");
		return errorReturn;
	}
	
	auto structData = split(input, "(");
	if (structData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Multiple '('");
		return errorReturn;
	}
	
	auto structInfo = split(structData[0], " ");
	if (structInfo.length != 2) {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Invalid struct information.");
		return errorReturn;
	}
	
	if (structInfo[0] != "struct") {
		reportError(fileName, lineNumber, "Invalid Struct Syntax", "Not a struct");
		return errorReturn;
	}
	
	AStructTuple returnStruct;
	returnStruct[0] = structInfo[1];
	return returnStruct;
}

// name, base
/**
*	Class tuple.
*/
alias AClassTuple = Tuple!(string,string);

/**
*	Tokenizes a class.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Class tuple for the class.
*/
auto tokenizeClass(string fileName, size_t lineNumber, string input) {
	AClassTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = null;
	
	if (!canFind(input, "(")) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Cannot find '('");
		return errorReturn;
	}
	if (!endsWith(input, ":")) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Does not end with ':'");
		return errorReturn;
	}
	
	auto classData = split(input, "(");
	if (classData.length != 2) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Multiple '('");
		return errorReturn;
	}
	
	string baseName;
	if (classData[1] != ":") {
		// parameters ...
		if (!endsWith(classData[1], ":")) {
			reportError(fileName, lineNumber, "Invalid Class Syntax", "':' location invalid.");
			return errorReturn;
		}
		baseName = classData[1][0 .. $-1];
	}
	else if (!endsWith(input, "(:")) { // No bases, but invalid syntax ...
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Does not end with '(:'");
		return errorReturn;
	}
	
	auto classInfo = split(classData[0], " ");
	if (classInfo.length != 2) {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Invalid class data!");
		return errorReturn;
	}
	
	if (classInfo[0] != "class") {
		reportError(fileName, lineNumber, "Invalid Class Syntax", "Not a class.");
		return errorReturn;
	}
	
	AClassTuple returnClass;
	returnClass[0] = classInfo[1];
	returnClass[1] = baseName;
	return returnClass;
}

//	Note:
//		Expressions do not report errors due to the fact there might be multiple expression validations. Some may fail, while otherwise will succeed.

// leftHand, operator, rightHand, isCall, params
/**
*	Expression Tuple.
*/
alias AExpressionTuple = Tuple!(string,string,string,bool,string[]);

/**
*	Enumeration of LOR operators.
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
*	Tokenizes an expression. (leftHand, operator, rightHand)
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Expression tuple for the expression.
*/
auto tokenizeExpression1(string fileName, size_t lineNumber, string input) {
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
	
	if (!canFind(AOperators1, expData[1])) {
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
private enum AOperators2 = [
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
	if (!canFind(AOperators2, op)) {
		return errorReturn;
	}
	
	AExpressionTuple expression;
	expression[0] = name;
	expression[1] = op;
	return expression;
}