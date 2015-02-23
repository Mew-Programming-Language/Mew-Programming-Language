/*
	This module is for tokenizing types and expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.tokenizer;

// Std Imports
import std.array;
import std.algorithm;
import std.conv : to;

// Mew Imports
import errors.report;

/**
*	Enumeration for data types
*/
enum AType : ushort {
	error,
	int8, int16, int32, int64,
	uint8, uint16, uint32, uint64,
	_float, _double, _real,
	_bool, _char, _string,
	_size_t, _ptrdiff_t,
	_struct, _class,
	_enum
}

/**
*	Enumeration for declarations
*/
enum ATypeDeclaration : ushort {
	single,
	array,
	list,
	map,
	orderlist,
	ordermap,
	linklist,
	stack,
	queue
}

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

//type1,type2,declaration,name,defaultValue,udt
/**
*	Type tuple.
*/
alias ATypeTuple = Tuple!(AType,AType,ATypeDeclaration,string,string,string);

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
*	Sets the type by a string reference.
*	Params:
*		type =		The type reference string.
*		dataType =	The data type to set.
*	Returns: True if the datatype was set.
*/
private bool setType(string type, ref AType dataType) {
	switch (type) {
		case "byte": dataType = AType.int8; break;
		case "short": dataType = AType.int16; break;
		case "int": dataType = AType.int32; break;
		case "long": dataType = AType.int64; break;
		case "ubyte": dataType = AType.uint8; break;
		case "ushort": dataType = AType.uint16; break;
		case "uint": dataType = AType.uint32; break;
		case "ulong": dataType = AType.uint64; break;
		case "float": dataType = AType._float; break;
		case "double": dataType = AType._double; break;
		case "real": dataType = AType._real; break;
		case "bool": dataType = AType._bool; break;
		case "char": dataType = AType._char; break;
		case "string": dataType = AType._string; break;
		case "size_t": dataType = AType._size_t; break;
		case "ptrdiff_t": dataType = AType._ptrdiff_t; break;
		
		default: {
			//onReportError("INVALID_VARIABLE_TYPE", 3);
			return false;
		}
	}
	return true;
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
	errorReturn[0] = AType.error;
	errorReturn[1] = AType.error;
	errorReturn[2] = ATypeDeclaration.single;
	errorReturn[3] = null;
	errorReturn[4] = null;
	errorReturn[5] = null;
	
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
	ATypeDeclaration declaration;
	bool isADT = false;
	foreach (adt; AbstractDataTypes) {
		if (startsWith(data[0], adt)) {
			if (data.length != 2) {
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
			
			declaration = to!ATypeDeclaration(adt);
			
			switch (adt) {
				case "array":
				case "list":
				case "orderlist":
				case "linklist":
				case "stack":
				case "queue": {
					if (canFind(arrayType, ":")) {
						reportError(fileName, lineNumber, "Invalid Variable Syntax", "Found ':' ... ':' is only avaiable for multi-type ADT's");
						return errorReturn;
					}
					break;
				}
				
				case "map":
				case "ordermap": {
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
		declaration = ATypeDeclaration.single;
	}
	
	AType dataType;
	AType dataType2 = AType.error;
	string udt;
	if (canFind(type, ":")) {
		auto types = split(type, ":");
		if (types.length != 2) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "More than one ':' found.");
			return errorReturn;
		}
		
		if (canFind(structs, types[0])) {
			dataType = AType._struct;
		}
		else if (canFind(classes, types[0])) {
			dataType = AType._class;
		}
		else if (canFind(enums, types[0])) {
			dataType = AType._enum;
		}
		else if (!setType(types[0], dataType)) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set first variable type.");
			return errorReturn;
		}
		
		if (canFind(structs, types[0])) {
			dataType2 = AType._struct;
		}
		else if (canFind(classes, types[0])) {
			dataType2 = AType._class;
		}
		else if (canFind(enums, types[0])) {
			dataType2 = AType._enum;
		}
		else if (!setType(types[1], dataType2)) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set secondary variable type.");
			return errorReturn;
		}
	}
	else if (canFind(structs, type)) {
		dataType = AType._struct;
		udt = type;
	}
	else if (canFind(classes, type)) {
		dataType = AType._class;
		udt = type;
	}
	else if (canFind(enums, type)) {
		dataType = AType._enum;
		udt = type;
	}
	else if (!setType(type, dataType)) {
		reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not set variable type.");
		return errorReturn;
	}
	
	if (data.length == 2) {
		ATypeTuple tupleReturn;
		tupleReturn[0] = dataType;
		tupleReturn[1] = dataType2;
		tupleReturn[2] = declaration;
		tupleReturn[3] = data[1];
		tupleReturn[4] = null;
		tupleReturn[5] = udt;
		return tupleReturn;
	}
	else if (dataType == AType._struct ||
		dataType == AType._class ||
		dataType == AType._enum ||
		dataType2 == AType._struct ||
		dataType2 == AType._class ||
		dataType2 == AType._enum) {
			// udt's cannot have values atm. ...
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
		if (dataType == AType._char) {
			if (!startsWith(valueSelect, "'") &&
				!endsWith(valueSelect, "'") ||
				valueSelect.length != 3) {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not parse char value.");
				return errorReturn;
			}
			valueSelect = to!string(valueSelect[1]);
		}
		else if (dataType == AType._string) {
			if (!startsWith(valueSelect, "\"") &&
			!endsWith(valueSelect, "\"")) {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Could not parse string value.");
				return errorReturn;
			}
			valueSelect = valueSelect[1 .. $-1];
		}
		else if (dataType == AType._bool) {
			if (valueSelect != "true" &&
				valueSelect != "false") {
				reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot parse boolean value.");
				return errorReturn;
			}
		}
		else if (!isNumericValue(valueSelect, (dataType == AType._float || dataType == AType._double || dataType == AType._real))) {
			reportError(fileName, lineNumber, "Invalid Variable Syntax", "Cannot parse numeric value.");
			return errorReturn;
		}
		
		ATypeTuple tupleReturn;
		tupleReturn[0] = dataType;
		tupleReturn[1] = dataType2;
		tupleReturn[2] = declaration;
		tupleReturn[3] = data[1];
		tupleReturn[4] = valueSelect;
		tupleReturn[5] = null;
		return tupleReturn;
	}
}

//name,returnType,parameters
/**
*	Task tuple
*/
alias ATaskTuple = Tuple!(string,AType,ATypeTuple[]);

/**
*	Tokenizes a task.
*	Params:
*		fileName =		The file name.
*		lineNumber =	The current line.
*		input =			The input to tokenize.
*	Returns: Task tuple for the task.
*/
auto tokenizeTask(string fileName, size_t lineNumber, string input, string[] structs, string[] classes, string[] enums) {
	AType returnType = AType.error;
	
	ATaskTuple errorReturn;
	errorReturn[0] = null;
	errorReturn[1] = AType.error;
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
	
	if (taskInfo.length == 3) {
		returnType = tokenizeVariable(fileName, lineNumber, taskInfo[1] ~ " " ~ taskInfo[2], structs, classes, enums)[0];
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
			if (paramTuple[0] == AType.error)
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

// leftHand, operator, rightHand
/**
*	Expression Tuple.
*/
alias AExpressionTuple = Tuple!(string,string,string);

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
	
	auto expData = split(input, " ");
	if (expData.length != 3) {
		return errorReturn;
	}
	
	if (!canFind(AOperators1, expData[1])) {
		return errorReturn;
	}
	
	AExpressionTuple expression;
	expression[0] = expData[0];
	expression[1] = expData[1];
	expression[2] = expData[2];
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