/*
	This module is for parsing mew modules.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.moduleparser;

// Std Imports
import std.string : format;
import std.array : replace, split;
import std.algorithm : strip, canFind, endsWith;

// Mew Imports
import errors.report;
import modules.naming;
import modules.sources;
import parser.tokenizer;
import parser.namevalidator;

// Type Related Imports
import parser.types.typecore;
import parser.types.moduletype;
import parser.types.structtype;
import parser.types.classtype;
import parser.types.variabletype;
import parser.types.tasktype;

/**
*	The parsed module names.
*/
private string[] parsedModules;

/**
*	The parsed modules.
*/
private Module[string] _modules;

/**
*	Prints all modules and their types/members.
*/
void printModules() {
	foreach (mod; _modules.values)
		mod.print();
}

/**
*	Module parser.
*/
class ModuleParser {
private:
	/**
	*	The module.
	*/
	Module m_module;
	/**
	*	The source.
	*/
	string[] m_source;
	/**
	*	The current line.
	*/
	size_t m_line;
	/**
	*	The file name.
	*/
	string m_fileName;
public:
	/**
	*	Creates a new instance of ModuleParser.
	*	Params:
	*		name =	The name of the module.
	*/
	this(string name) {
		auto m = _modules.get(name, null);
		if (!m)
			m_module = new Module(name);
		else
			m_module = m;
		m_line = 0;
	}
	
	@property {
		/**
		*	Gets the module.
		*/
		Module mod() { return m_module; }
	}
	
	/**
	*	Initializes a module for parsing.
	*	Params:
	*		importer =			The module importing this module.
	*		lineNumber =		The line number.
	*		ignoreImporter =	A boolean determining whether the importer should be ignored or not.
	*	Returns: True if the module was initialized successfully, false otherwise.
	*/
	bool initialize(string importer, size_t lineNumber = size_t.max, bool ignoreImporter = false) {
		string importerFile = getModuleByName(importer);
		// Checks whether the importer is valid.
		if (!importerFile && !ignoreImporter) {
			reportError("Compiler", lineNumber, "Module Failed Init", format("Cannot initialize module importing for '%s'", importer));
			return false;
		}
		else if (ignoreImporter) {
			importer = "Compiler";
			importerFile = "Compiler";
		}
		
		// Checks if the module has a file.
		m_fileName = getModuleByName(m_module.name);
		if (!m_fileName) {
			reportError(importerFile, lineNumber, "Module Not Found", format("Cannot import module '%s' from module '%s'", m_module.name, importer));
			return false;
		}
		
		// Checks if the source of the module can be loaded.
		if (!loadSourceByName(m_module.name)) {
			reportError(importerFile, lineNumber, "Module Not Found", format("Cannot import module '%s' from module '%s'", m_module.name, importer));
			return false;
		}
		
		// Checks if the source of the module could be retrieved.
		string source = getSourceByName(m_module.name);
		if (!source) {
			reportError(m_fileName, lineNumber, "Module Failed Init", format("Cannot initialize module source for '%s'", m_module.name));
			return false;
		}
		
		// Splits the source by its lines.
		m_source = split(source, "\n");
		
		return true;
	}
	
	/**
	*	Parses a module by its source.
	*/
	void parse() {
		// checks whether the module exists and if it does don't parse again.
		if (canFind(parsedModules, m_fileName))
			return;
		parsedModules ~= m_fileName;
		_modules[m_module.name] = m_module;
		
		// Parsing scope settings
		bool inMultiLineComment = false;
		bool resetAttributes = false;
		string[] attributes;
		string[string] aliases;
		ModifierAccess1 modifier1 = ModifierAccess1._public;
		ModifierAccess2 modifier2 = ModifierAccess2.none;
		
		// Loops through the source by its lines
		while (m_line < m_source.length) {
			string line = strip(m_source[m_line], '\0');
			line = strip(line, '\t');
			line = strip(line, ' ');
			line = strip(line, '\r');
			if (!line || !line.length) {
				m_line++;
				continue;
			}
			
			// Checks for single line comment
			if (line[0] == '#') {
				m_line++;
				continue;
			}
			
			// Checks for multi line comment
			if (inMultiLineComment) {
				if (line == "+/")
					inMultiLineComment = false;
				m_line++;
				continue;
			}
			else if (line == "/+") {
				inMultiLineComment = true;
				m_line++;
				continue;
			}
			
			// Attribute handling
			if (resetAttributes)
				attributes = null;
				
			if (line[0] == '@') {
				attributes ~= line;
				m_line++;
				resetAttributes = false;
				continue;
			}
			else
				resetAttributes = true;
			
			// Checks if the line is the module aliasing ...
			if (line == "module " ~ m_module.name) {
				m_line++;
				continue;
			}
			
			// Replaces alias expressions
			foreach (k, v; aliases) {
				line = replace(line, k, v); // store information about alias + line later to report errors that are based on aliases
			}
			
			bool wasModifier = false;
			switch (line) {
				// ModifierAccess1
				case "public:":
					modifier1 = ModifierAccess1._public;
					wasModifier = true;
					break;
				case "protected:":
					modifier1 = ModifierAccess1._protected;
					wasModifier = true;
					break;
				case "private:":
					modifier1 = ModifierAccess1._private;
					wasModifier = true;
					break;
				case "personal:":
					modifier1 = ModifierAccess1._personal;
					wasModifier = true;
					break;
					
				// ModifierAccess2
				case "none:":
					modifier2 = ModifierAccess2.none;
					wasModifier = true;
					break;
				case "const:":
					modifier2 = ModifierAccess2._const;
					wasModifier = true;
					break;
				case "immutable:":
					modifier2 = ModifierAccess2._immutable;
					wasModifier = true;
					break;
				case "scope:":
					modifier2 = ModifierAccess2._scope;
					wasModifier = true;
					break;
				
				// Clear
				case "clear:":
					modifier1 = ModifierAccess1._public;
					modifier2 = ModifierAccess2.none;
					wasModifier = true;
					break;
				
				// not a modifier access
				default: break;
			}
			if (wasModifier) {
				m_line++;
				continue;
			}
			// Splits the current line by space ... " "
			scope auto lineSplit = split(line, " ");
			
			switch (lineSplit[0]) {
				case "alias": {
					import parser.aliasparser;
					parseAlias(m_fileName, m_line, line, lineSplit, aliases);
					break;
				}
				
				case "import": {
					if (lineSplit.length != 2) {
						reportError(m_fileName, m_line, "Invalid Syntax", "Invalid import syntax.");
					}
					else {
						string importModuleName = lineSplit[1];
			
						scope auto importParser = new ModuleParser(importModuleName);
						if (importParser.initialize(m_module.name, m_line)) {
							importParser.parse();
							auto importModule = importParser.mod;
							m_module.addImport(importModule);
						}
					}
					break;
				}
				
				case "include": {
					if (lineSplit.length != 2) {
						reportError(m_fileName, m_line, "Invalid Syntax", "Invalid include syntax.");
					}
					else {
						string includeName = lineSplit[1];
						if (includeName.length < 3) {
							reportError(m_fileName, m_line, "Invalid Syntax", "Invalid include string length.");
						}
						else {
							if (includeName[0] != '"' || includeName[$-1] != '"') {
								reportError(m_fileName, m_line, "Invalid Syntax", "Include value doesn't take a string.");
							}
							else {
								includeName = includeName[1 .. $-1];
								if (!endsWith(includeName, ".h")) {
									reportError(m_fileName, m_line, "Invalid Include", "Include value is not a C-header file.");
								}
								else
									m_module.addInclude(includeName);
							}
						}
					}
					break;
				}
				
				case "cextern": {
					if (lineSplit.length != 2) {
						reportError(m_fileName, m_line, "Invalid Syntax", "Invalid cextern syntax.");
					}
					else {
						m_module.addCExtern(lineSplit[1]);
					}
					break;
				}
				
				case "task": {
					size_t cline = m_line;
					import parser.taskparser;
					scope auto taskParser = new TaskParser();
					taskParser.parse(
						m_fileName, m_line, m_source, attributes, aliases,
						m_module.globalVariables,
						m_module,
						modifier1, modifier2
					);
					if (taskParser.task) {
						if (!m_module.addGlobalTask(taskParser.task))
							reportError(m_fileName, cline, "Duplicate", "Task name conflicting with an earlier local task.");
					}
					break;
				}
				
				case "struct": {
					size_t cline = m_line;
					import parser.structparser;
					scope auto structParser = new StructParser();
					structParser.parse(
						m_fileName, m_line, m_source, attributes, aliases,
						m_module.globalVariables,
						m_module,
						modifier1, modifier2
					);
					/*if (structParser.strc) {
						if (!m_module.addStruct(structParser.strc)) {
							reportError(m_fileName, cline, "Duplicate", "Struct name conflicting with an earlier local struct.");
						}
					}*/
					break;
				}
				
				case "class": {
					size_t cline = m_line;
					import parser.classparser;
					scope auto classParser = new ClassParser();
					classParser.parse(
						m_fileName, m_line, m_source, attributes, aliases,
						m_module.globalVariables,
						m_module,
						m_module.classes,
						modifier1, modifier2
					);
					/*if (classParser.cls) {
						if (!m_module.addClass(classParser.cls)) {
							reportError(m_fileName, cline, "Duplicate", "Class name conflicting with an earlier local class.");
						}
					}*/
					break;
				}
				case "enum": {
					break;
				}
				
				default: {
					size_t cline = m_line;
					import parser.variableparser;
					scope auto variableParser = new VariableParser!Variable;
					if (variableParser.parse(m_fileName, m_line, line, attributes, modifier1, modifier2, m_module.structs.keys ~ m_module.cextern, m_module.classes.keys, null) && variableParser.var) {
						if (!m_module.addGlobalVar(variableParser.var))
							reportError(m_fileName, m_line, "Duplicate", "Variable name conflicting with an earlier local variable.");
					}
					else {
						// reportError(m_fileName, m_line, "Invalid Syntax", "Invalid syntax or non-parsable code.");
					}
					break;
				}
			}
			
			m_line++;
		}
	}
}