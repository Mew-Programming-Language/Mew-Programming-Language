/*
	This module is for parsing mew classes.
	
	Authors:
		Jacob Jensen / Bauss
*/
module parser.classparser;

// Std Imports
import std.string : format;
import std.array : replace, split;
import std.algorithm : strip, canFind, startsWith, endsWith;

// Mew Imports
import errors.report;
import parser.parsingtypes;
import parser.tokenizer;
import parser.namevalidator;

/**
*	Class parser.
*/
class ClassParser {
private:
	/**
	*	The class.
	*/
	Class m_class;
public:
	/**
	*	Creates a new instance of ClassParser.
	*/
	this() {
		// Reserved for future use ...
	}
	
	@property {
		/**
		*	Gets the Class.
		*/
		Class cls() { return m_class; }
	}
	
	/**
	*	Parses a class.
	*	Params:
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		source =			(ref) The source.
	*		attributes =		The attributes.
	*		ialiases =			The inheritance aliases.
	*/
	void parse(string fileName, ref size_t lineNumber, ref string[] source, string[] attributes, string[string] ialiases,
		Variable[string] inheritedVariables, Class[string] classes) {
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
			
			bool isConstructor = false;
			if (startsWith(line, "this(") && endsWith(line, ":")) { // constructor ...
				line = "task " ~ line; // makes it valid for parsing ...
				source[lineNumber] = line;
				isConstructor = true;
			}
			
			if (startsWith(line, "~this(") && endsWith(line, ":")) { // destructor ...
				line = "task __free_" ~ line[1 .. $]; // makes it valid for parsing ...
				source[lineNumber] = line;
				isConstructor = true;
			}
			
			// Splits the current line by space ... " "
			scope auto lineSplit = split(line, " ");
			
			switch (lineSplit[0]) {
				case "alias": {
					import parser.aliasparser;
					parseAlias(fileName, lineNumber, line, lineSplit, aliases);
					break;
				}
				
				case "class": {
					if (m_class) {
						reportError(fileName, lineNumber, "Invalid Class Syntax", "Nested classes are disallowed.");
						return;
					}
					auto tokenized = tokenizeClass(fileName, lineNumber, line);
					auto name = tokenized[0];
					if (!name)
						break;
					if (!validName(name)) {
						reportError(fileName, lineNumber, "Invalid Name", "Invalid class name. Make sure it's A-Z and doesn't conflic with keywords.");
						return;
					}
					auto parent = tokenized[1];
					if (!parent)
						m_class = new Class(name, attributes, inheritedVariables, null);
					else if (parent in classes) {
						m_class = new Class(name, attributes, inheritedVariables, classes[parent]);
					}
					else {
						reportError(fileName, lineNumber, "Invalid Inheritance", format("'%s' cannot inherit '%s', because it wasn't found!", name, parent));
					}
					break;
				}
				
				case "task": {
					size_t cline = lineNumber;
					import parser.taskparser;
					scope auto taskParser = new TaskParser();
					taskParser.parse(
						fileName, lineNumber, source, attributes, aliases,
						inheritedVariables, isConstructor
					);
					if (taskParser.task) {
						if (!m_class.addTask(taskParser.task))
							reportError(fileName, cline, "Duplicate", "Task name conflicting with an earlier local task.");
					}
					break;
				}
				
				default: {
					size_t cline = lineNumber;
					import parser.variableparser;
					scope auto variableParser = new VariableParser!StructVariable;
					if (variableParser.parse(fileName, lineNumber, line, attributes) && variableParser.var) {
						if (!m_class.addVar(variableParser.var))
							reportError(fileName, cline, "Duplicate", "Variable name conflicting with an earlier local variable.");
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
			if (m_class)
				reportError(fileName, lineNumber, "Invalid Class Syntax", format("Missing ')' for class '%s'", m_class.name));
			else
				reportError(fileName, lineNumber, "Invalid Class Syntax", "Class parsed incorrectly.");
		}
	}
}