/*
	This module is for parsing mew structs.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.structparser;

// Std Imports
import std.string : format;
import std.array : replace, split;
import std.algorithm : strip, canFind, startsWith, endsWith;

// Mew Imports
import errors.report;
import parser.tokenizers.tokenizercore;
import parser.namevalidator;
import parser.parserhandlers;

// Type Related Imports
import parser.types.typecore;
import parser.types.moduletype;
import parser.types.structtype;
import parser.types.variabletype;
import parser.types.tasktype;

/**
*	Struct parser.
*/
class StructParser {
private:
	/**
	*	The struct.
	*/
	Struct m_struct;
public:
	/**
	*	Creates a new instance of StructParser.
	*/
	this() {
		// Reserved for future use ...
	}
	
	@property {
		/**
		*	Gets the Struct.
		*/
		Struct strc() { return m_struct; }
	}
	
	/**
	*	Parses a struct.
	*	Params:
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		source =			(ref) The source.
	*		attributes =		The attributes.
	*		ialiases =			The inheritance aliases.
	*/
	void parse(string fileName, ref size_t lineNumber, ref string[] source, string[] attributes, string[string] ialiases,
		Variable[string] inheritedVariables, Module mod,
		ModifierAccess1 _modifier1, ModifierAccess2 _modifier2) {
		// Parsing scope settings
		bool foundEndStatement = false;
		bool inMultiLineComment = false;
		bool resetAttributes = false;
		string[string] aliases;
		// Sets the inherited aliases.
		foreach (k, v; ialiases)
			aliases[k] = v;
		ModifierAccess1 modifier1 = _modifier1;
		ModifierAccess2 modifier2 =_modifier2;
		
		// Loops through the source by its lines
		while (lineNumber < source.length) {
			string line = strip(source[lineNumber], '\0');
			bool isConstructor = false;
			
			
			string parserName = "struct";
			mixin ParseHandler!(ParserType._struct);
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
				
				case "struct": {
					if (m_struct) {
						reportError(fileName, lineNumber, "Invalid Struct Syntax", "Nested structs are disallowed.");
						return;
					}
					scope auto tokenized = tokenizeStruct(fileName, lineNumber, line);
					auto name = tokenized[0];
					if (!name)
						break;
					if (!validName(name)) {
						reportError(fileName, lineNumber, "Invalid Name", "Invalid struct name. Make sure it's A-Z and doesn't conflic with keywords.");
						return;
					}
					m_struct = new Struct(name, attributes, inheritedVariables, modifier1, modifier2);
					modifier1 = ModifierAccess1._public;
					modifier2 = ModifierAccess2.none;
					
					if (!mod.addStruct(m_struct)) {
						reportError(fileName, lineNumber, "Duplicate", "Struct name conflicting with an earlier local struct.");
					}
					break;
				}
				
				case "task": {
					size_t cline = lineNumber;
					import parser.taskparser;
					scope auto taskParser = new TaskParser();
					taskParser.parse(
						fileName, lineNumber, source, attributes, aliases,
						cast(Variable[string])m_struct.childVariables,
						m_struct.tasks,
						mod,
						modifier1, modifier2,
						isConstructor,
						m_struct
					);
					if (taskParser.task) {
						if (!m_struct.addTask(taskParser.task))
							reportError(fileName, cline, "Duplicate", "Task name conflicting with an earlier local task.");
					}
					break;
				}
				
				default: {
					size_t cline = lineNumber;
					import parser.variableparser;
					scope auto variableParser = new VariableParser!StructVariable;
					if (variableParser.parse(fileName, lineNumber, line, attributes, modifier1, modifier2, mod.structs.keys ~ mod.cextern, mod.classes.keys, null) && variableParser.var) {
						if (!m_struct.addVar(variableParser.var))
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
			if (m_struct)
				reportError(fileName, lineNumber, "Invalid Struct Syntax", format("Missing ')' for struct '%s'", m_struct.name));
			else
				reportError(fileName, lineNumber, "Invalid Struct Syntax", "Struct parsed incorrectly.");
		}
	}
}