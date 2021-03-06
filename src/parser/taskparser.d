/*
	This module is for parsing mew tasks.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.taskparser;

// Std Imports
import std.string : format;
import std.array : replace, split;
import std.algorithm : strip, canFind;

// Mew Imports
import errors.report;
import parser.tokenizers.tokenizercore;
import parser.namevalidator;
import parser.expressionparser;
import parser.parserhandlers;
import parser.taskhandlers;

// Type Related Imports
import parser.types.typecore;
import parser.types.moduletype;
import parser.types.variabletype;
import parser.types.tasktype;
import parser.types.expressions;

/**
*	Task parser.
*/
class TaskParser {
private:
	/**
	*	The task.
	*/
	Task m_task;
public:
	/**
	*	Creates a new instance of TaskParser.
	*/
	this() {
		// Reserved for future use ...
	}
	
	@property {
		/**
		*	Gets the task.
		*/
		Task task() { return m_task; }
	}
	
	/**
	*	Parses a task.
	*	Params:
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		source =			(ref) The source.
	*		attributes =		The attributes.
	*		ialiases =			The inheritance aliases.
	*/
	void parse(string fileName, ref size_t lineNumber, ref string[] source, string[] attributes, string[string] ialiases,
		Variable[string] inheritedVariables, Task[string] inheritedTasks, Module mod, ModifierAccess1 modifier1, ModifierAccess2 modifier2, bool isConstructor = false, ParentType parent = null) {
		// Parsing scope settings
		bool foundEndStatement = false;
		bool foundReturnStatement = false;
		bool inMultiLineComment = false;
		bool resetAttributes = false;
		string[string] aliases;
		// Sets the inherited aliases.
		foreach (k, v; ialiases)
			aliases[k] = v;
		
		// Loops through the source by its lines
		while (lineNumber < source.length) {
			string line = strip(source[lineNumber], '\0');
			
			string parserName = "task";
			mixin ParseHandler!(ParserType._task);
			auto res = handleParser(lineNumber); // uses lineNumber ...
			if (res == CONTINUE)
				continue;
			else if (res == BREAK)
				break;
			else if (res == RETURN)
				return;
			// else if (res == NOTHING)
			
			// Splits the current line by space ... " "
			scope auto lineSplit = split(line, " ");
			
			switch (lineSplit[0]) {
				case "alias": {
					import parser.aliasparser;
					parseAlias(fileName, lineNumber, line, lineSplit, aliases);
					break;
				}
				
				case "task": {
					if (m_task) {
						reportError(fileName, lineNumber, "Invalid Task Syntax", "Nested tasks are disallowed.");
						return;
					}
					scope auto tokenized = tokenizeTask(fileName, lineNumber, line, mod.structs.keys, mod.classes.keys, null);
					
					auto name = tokenized[0];
					if (!name)
						break;
					if (!validName(name, isConstructor)) {
						reportError(fileName, lineNumber, "Invalid Name", "Invalid task name. Make sure it's A-Z and doesn't conflic with keywords.");
						return;
					}
					auto returnType = tokenized[1];
					
					auto parameters = tokenized[2];	

					Variable[] params;
					foreach (param; parameters) {
						import parser.variableparser;
						scope auto variableParser = new VariableParser!Variable;
						variableParser.parse2(param, fileName, lineNumber, line, null, ModifierAccess1._private, ModifierAccess2.none);
						if (variableParser.var) {
							params ~= variableParser.var;
						}
					}
					
					if (mod.name == "main" && name == "main" && params) {
						reportError(fileName, lineNumber, "Invalid Params", "Main task cannot take parameters.");
						return; // only allow void parameters atm. do args later ...
					}
					
					m_task = new Task(name, returnType, params, attributes, inheritedVariables, inheritedTasks, modifier1, modifier2, parent);
					break;
				}
				
				case "return": {
					mixin ReturnStatement;
					if (!handleReturnStatement())
						return;
					break;
				}
				
				case "if": {
					mixin IfStatement;
					handleIfStatement();
					//if (!handleIfStatement())
					//	return;
					break;
				}
				
				default: {
					mixin ExpStatement;
					if (!handleExpStatement())
						return;
					break;
				}
			}
			lineNumber++;
		}
		// There was no ending statement found and it reached the end of the file ...
		if (!foundEndStatement) {
			if (m_task)
				reportError(fileName, lineNumber, "Invalid Task Syntax", format("Missing ')' for task '%s'", m_task.name));
			else
				reportError(fileName, lineNumber, "Invalid Task Syntax", "Task parsed incorrectly.");
		}
		else if (!foundReturnStatement && m_task.returnType && m_task.returnType != "void") {
			if (m_task)
				reportError(fileName, lineNumber, "Invalid Task Syntax", format("Missing return for task '%s'", m_task.name));
			else
				reportError(fileName, lineNumber, "Invalid Task Syntax", "Task parsed incorrectly.");
		}
	}
}