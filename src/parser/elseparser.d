/*
	This module is for parsing else statements.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.elseparser;

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
*	Else parser.
*/
class ElseParser {
private:
	/**
	*	The task.
	*/
	Task m_task;
	/**
	*	The expression.
	*/
	string[] m_expression;
public:
	/**
	*	Creates a new instance of IfParser.
	*/
	this(Task task) {
		m_task = task;
	}
	
	@property {
		/**
		*	Gets the task.
		*/
		Task task() { return m_task; }
		
		/**
		*	Gets the expression.
		*/
		string[] expression() { return m_expression; }
	}
	
	/**
	*	Parses an else statement.
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
		bool foundReturnStatement = false; // Ignored and only used to parse "return" properly.
		bool inMultiLineComment = false;
		bool resetAttributes = false;
		bool parsedIf = false;
		bool doneParsing = false;
		string[string] aliases;
		// Sets the inherited aliases.
		foreach (k, v; ialiases)
			aliases[k] = v;
		
		// Loops through the source by its lines
		while (lineNumber < source.length) {
			string line = strip(source[lineNumber], '\0');
			
			string nextLine;
			if (lineNumber < (source.length - 1)) {
				nextLine = strip(source[lineNumber + 1], '\0');
				nextLine = strip(nextLine, '\t');
				nextLine = strip(nextLine, ' ');
				nextLine = strip(nextLine, '\r');
			}
			string parserName = "else";
			mixin ParseHandler!(ParserType._else);
			auto res = handleParser(lineNumber); // uses lineNumber ...
			import std.stdio;
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
				
				case "if": {
					mixin IfStatement;
					handleIfStatement();
					break;
				}
				
				case "return": {
					mixin ReturnStatement;
					if (!handleReturnStatement())
						return;
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
				reportError(fileName, lineNumber, "Invalid Else Syntax", format("Missing ')' for else statement in '%s'", m_task.name));
			else
				reportError(fileName, lineNumber, "Invalid Else Syntax", "If statement parsed incorrectly.");
		}
	}
}