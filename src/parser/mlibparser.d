/*
	This module is for Mew Library parsing.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.mlibparser;

import std.array : replace, join;
import std.string : format;

// Type Related Imports
import parser.types.typecore;
import parser.types.moduletype;
import parser.types.structtype;
import parser.types.classtype;
import parser.types.variabletype;
import parser.types.tasktype;
import parser.types.expressions;

private string[] sourceNames;

private size_t lastDefId = 0;
private size_t[string] definitions;

private string[] variables;
private string[] structs;
private string[] _expressions;
private string[] functions;

string parseSource(Module mod) {
	string src;
	string defStr = "def %s %s";
	
	src ~= "// Imports\r\n";
	src ~= join(parseModule(mod), "\r\n");
	
	src ~= "// Definitions\r\n";
	foreach (k, v; definitions) {
		src ~= format(defStr, v, k) ~ "\r\n";
	}
	
	src ~= "// Variables\r\n";
	src ~= join(variables, "\r\n");
	src ~= "\r\n";
	
	src ~= "// Structs\r\n";
	src ~= join(structs, "\r\n");
	src ~= "\r\n";
	
	src ~= "// Expressions\r\n";
	src ~= join(_expressions, "\r\n");
	src ~= "\r\n";
	
	src ~= "// Functions\r\n";
	src ~= join(functions, "\r\n");
	src ~= "\r\n";
	
	src ~= "// Sources\r\n";
	src ~= join(sourceNames, "\r\n");
	src ~= "\r\n";
	
	return src;
}

private string[] parseModule(Module mod) {
	string importStr = "import %s %s %s %s";
	string strcStr = "struct %s %s %s";
	
	sourceNames ~= "source Mew_" ~ replace(mod.name, ".", "_");
	string location = "Mew_" ~ replace(mod.name, ".", "_");
	
	string[] src;
	
	foreach (m; mod.imports) {
		src ~= format(importStr, "Mew_" ~ replace(m.name, ".", "_"), "false", "0", location);
	}
	
	foreach (var; mod.initVariables.values) {
		parseVariable(var, 0, location);
	}
	
	foreach (task; mod.initTasks.values) {
		if (mod.name == "main")
			parseTask(task, "Mew_" ~ task.name, 0, location, null);
		else
			parseTask(task, task.name, 0, location, null);
	}
	
	foreach (strc; mod.initStructs.values) {
		structs ~= format(strcStr, strc.name, "0", location);
		foreach (var; strc.initVariables) {
			// check for @align attribute ...
			// do alignment by inserting empty byte variable ...
			parseVariable(var, 1, strc.name);
		}
		foreach (task; strc.initTasks.values) {
			parseTask(task, strc.name ~ "_" ~ task.name, 0, location, strc.name);
		}
	}
	
	foreach (cls; mod.initClasses.values) {
		// TODO: Parent -> child reference for casting ...
	
		structs ~= format(strcStr, cls.name, "0", location);
		foreach (var; cls.initVariables.values) {
			parseVariable(var, 1, cls.name);
		}
		foreach (task; cls.initTasks.values) {
			parseTask(task, cls.name ~ "_" ~ task.name, 0, location, cls.name);
		}
	}
	
	foreach (m; mod.imports) {
		src ~= parseModule(m);
	}
	
	return src;
} 

private void parseVariable(Variable var, size_t loc, string locName) {
	string varStr = "var %s %s %s %s %s";
	string ctype = var.type;
	string name = var.name;
	
	string value = var.defaultValue;
	if (ctype == "Array_string") {
		value = "\"" ~ value ~ "\"";
		name = name ~ "[]";
	}
	else if (ctype == "char" || ctype == "unsigned char")
		value = "'" ~ value ~ "'";
		
	if (value) {
		size_t key;
		bool foundKey = false;
		foreach (k, v; definitions) {
			if (k == value) {
				key = v;
				foundKey = true;
				break;
			}
		}
		if (!foundKey) {
			lastDefId++;
			key = lastDefId;
			definitions[value] = key;
		}
					
		variables ~= format(varStr, var.type, name, loc, locName, key);
	}
	else {
		variables ~= format(varStr, var.type, name, loc, locName, "0");
	}
}

private void parseTask(Task task, string name, size_t loc, string locName, string parent) {
	string funcStr = "func %s %s %s %s %s";
	string paramStr = "%s|%s";
	string expStr = "exp %s %s %s %s";
	string rtype = (task.returnType ? task.returnType : "void");
	
	if (!task.parameters) {
		if (parent)
			functions ~= format(funcStr, rtype, name, parent ~ "|*this", loc, locName);
		else
			functions ~= format(funcStr, rtype, name, "void", loc, locName);
	}
	else {
		string[] params;
		if (parent)
			params = [parent ~ "|*this"];
		foreach (param; task.parameters) {
			// Implement expressions for default values ...
			params ~= format(paramStr, param.type, param.name);
		}
		functions ~= format(funcStr, rtype, name, join(params, ","), loc, locName);
	}
	
	size_t id = 0;
	
	foreach (var; task.initVariables) {
		// do class checks to init constructor ...
		_expressions ~= format(expStr, id, 2, name, format("%s %s;", var.type, var.name));
		id++;
	}
	
	foreach (exp; task.expressions) {
		if (exp.expressionType != ExpressionType.LORCall) {
			if (parent)
				_expressions ~= format(expStr, id, 2, name, "this->" ~ exp.toString());
			else
				_expressions ~= format(expStr, id, 2, name, exp.toString());
		}
		else {
			if (parent)
				_expressions ~= format(expStr, id, 2, name, (cast(LORCallExpression)exp).toString("this"));
			else
				_expressions ~= format(expStr, id, 2, name, exp.toString());
		}
		id++;
	}
}