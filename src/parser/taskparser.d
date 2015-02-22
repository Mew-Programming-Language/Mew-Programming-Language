/*
	This module is for parsing mew tasks.
	
	Authors:
		Jacob Jensen / Bauss
*/
module parser.taskparser;

// Std Imports
import std.string : format;
import std.array : replace, split;
import std.algorithm : strip, canFind;

// Mew Imports
import errors.report;
import parser.parsingtypes;
import parser.tokenizer;

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
		Variable[string] inheritedVariables) {
		// Parsing scope settings
		bool foundEndStatement = false;
		bool inMultiLineComment = false;
		bool resetAttributes = false;
		string[string] aliases;
		// Sets the inherited aliases.
		foreach (k, v; ialiases)
			aliases[k] = v;
		
		// Loops through the source by its lines
		while (lineNumber < source.length) {
			string line = strip(source[lineNumber], '\0');
			line = strip(line, '\t');
			line = strip(line, ' ');
			line = strip(line, '\r');
			if (!line || !line.length) {
				lineNumber++;
				continue;
			}
			
			// Checks if it's an ending statement
			if (line == ")") {
				foundEndStatement = true;
				break;
			}
			
			// Checks for single comment
			if (line[0] == '#') {
				lineNumber++;
				continue;
			}
			
			// Checks for multi line comment
			if (inMultiLineComment) {
				if (line == "+/")
					inMultiLineComment = false;
				lineNumber++;
				continue;
			}
			else if (line == "/+") {
				inMultiLineComment = true;
				lineNumber++;
				continue;
			}
			
			// Attribute handling
			if (resetAttributes)
				attributes = null;
				
			if (line[0] == '@') {
				attributes ~= line;
				lineNumber++;
				resetAttributes = false;
				continue;
			}
			else
				resetAttributes = true;
			
			// Replaces alias expressions
			foreach (k, v; aliases) {
				line = replace(line, k, v); // store information about alias + line later to report errors that are based on aliases
			}
			
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
					auto tokenized = tokenizeTask(fileName, lineNumber, line);
					auto name = tokenized[0];
					if (!name)
						break;
					auto returnType = tokenized[1];
					
					auto parameters = tokenized[2];		
					Variable[] params;
					foreach (param; parameters) {
						import parser.variableparser;
						scope auto variableParser = new VariableParser();
						variableParser.parse2(param, null);
						if (variableParser.var) {
							params ~= variableParser.var;
						}
					}
					
					m_task = new Task(name, returnType, params, attributes, inheritedVariables);
					break;
				}
				
				default: {
					import parser.variableparser;
					scope auto variableParser = new VariableParser();
					if (variableParser.parse(fileName, lineNumber, line, null) && variableParser.var) {
						m_task.addVar(variableParser.var);
					}
					else {
						// parse instructions ...
					}
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
	}
}