/*
	Mew types that are parsable.
	
	Authors:
		Jacob Jensen / Bauss
*/
module parser.parsingtypes;

// Mew Imports
import parser.tokenizer : AType, ATypeDeclaration;

/**
*	Module Type
*/
class Module {
private:
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The imports.
	*/
	Module[] m_imports;
	/**
	*	The global variables.
	*/
	Variable[string] m_globalVariables;
	/**
	*	The global tasks.
	*/
	Task[string] m_globalTasks;
public:
	/**
	*	Creates a new instance of Module.
	*	Params:
	*		name =	The name of the module.
	*/
	this(string name) {
		m_name = name;
	}
	
	@property {
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
		
		/**
		*	Gets the imports.
		*/
		Module[] imports() { return m_imports; }
		
		/**
		*	Gets the global variables.
		*/
		Variable[string] globalVariables() { return m_globalVariables; }
		
		/**
		*	Gets the global tasks.
		*/
		Task[string] globalTasks() { return m_globalTasks; }
	}
	
	/**
	*	Adds an import.
	*	Params:
	*		mod =	The module to add as an import.
	*/
	void addImport(Module mod) {
		m_imports ~= mod;
		foreach (var; mod.m_globalVariables.values)
			m_globalVariables[var.name] = var;
		foreach (task; mod.globalTasks.values)
			m_globalTasks[task.name] = task;
	}
	
	/**
	*	Adds a global variable.
	*	Params:
	*		var =	The variable to add.
	*/
	void addGlobalVar(Variable var) {
		m_globalVariables[var.name] = var;
	}
	
	/**
	*	Adds a global task.
	*	Params:
	*		task =	The task to add.
	*/
	void addGlobalTask(Task task) {
		m_globalTasks[task.name] = task;
	}
	
	/**
	*	Prints the module and its types / members.
	*/
	void print() {
		import std.stdio : writeln, writefln;
		writefln("Module: %s", m_name);
		if (m_imports) {
			writeln("\tImports:");
			foreach (imp; m_imports) {
				writefln("\t\t%s", imp.name);
				writeln();
			}
		}
		else
			writeln("\tImports: N/A");
			
		if (m_globalVariables) {
			writeln("\tGlobal Vars:");
			foreach (var; m_globalVariables) {
				var.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tGlobal Vars: N/A");
			
		if (m_globalTasks) {
			writeln("\tGlobal Tasks:");
			foreach (task; m_globalTasks) {
				task.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tGlobal Tasks: N/A");
		
		// classes, structs etc.
	}
}

/**
*	Variable Type.
*/
class Variable {
private:
	/**
	*	The first type.
	*/
	AType m_type1;
	/**
	*	The secondary type.
	*	Note: Error also equals no secondary type.
	*/
	AType m_type2;
	/**
	*	The declaration.
	*/
	ATypeDeclaration m_declaration;
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The default value.
	*/
	string m_defaultValue;
	/**
	*	The attributes.
	*/
	string[] m_attributes;
public:
	/**
	*	Creates a new instance of Variable.
	*	Params:
	*		type =				The type.
	*		name =				The name.
	*		defaultValue =		The default value. (null for nothing.)
	*		attributes =		The attributes.
	*/
	this(AType type, string name, string defaultValue, string[] attributes) {
		m_type1 = type;
		m_declaration = ATypeDeclaration.single;
		m_name = name;
		m_defaultValue = defaultValue;
		m_attributes = attributes;
	}
	
	/**
	*	Creates a new instance of Variable.
	*	Params:
	*		declaration = 	The declaration.
	*		type1 =			The first type.
	*		type2 =			The second type.
	*		name =			The name.
	*		attributes =	The attributes.
	*/
	this(ATypeDeclaration declaration, AType type1, AType type2, string name, string[] attributes) {
		m_type1 = type1;
		m_type2 = type2;
		m_declaration = declaration;
		m_name = name;
		m_defaultValue = defaultValue;
		m_attributes = attributes;
	}
	
	@property {
		/**
		*	Gets the first type.
		*/
		AType type1() { return m_type1; }
		/**
		*	Gets the second type.
		*/
		AType type2() { return m_type2; }
		/**
		*	Gets the declaration.
		*/
		ATypeDeclaration declaration() { return m_declaration; }
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
		/**
		*	Gets the default value.
		*/
		string defaultValue() { return m_defaultValue; }
		/**
		*	Gets the attributes.
		*/
		string[] attributes() { return m_attributes; }
	}
	
	/**
	*	Prints the variable.
	*	Params:
	*		tabs =		The amount of tabs to print.
	*/
	void print(string tabs) {
		import std.stdio : writefln;
		if (m_declaration == ATypeDeclaration.single) {
			writefln("%sVariable:", tabs);
			writefln("%s\tType: %s", tabs, m_type1);
			writefln("%s\tName: %s", tabs, m_name);
			if (m_defaultValue)
				writefln("%s\tDefault Value: %s", tabs, m_defaultValue);
			else
				writefln("%s\tDefault Value: N/A", tabs);
		}
		else {
			writefln("%sVariable:", tabs);
			writefln("%s\tDeclaration: %s", tabs, m_declaration);
			writefln("%s\tType 1: %s", tabs, m_type1);
			writefln("%s\tType 2: %s", tabs, m_type2);
			writefln("%s\tName: %s", tabs, m_name);
		}
		if (m_attributes) {
			writefln("%s\tAttributes:", tabs);
			foreach (attr; m_attributes) {
				writefln("%s\t\t%s", tabs, attr);
			}
		}
		else
			writefln("%s\tAttributes: N/A", tabs);
	}
}

/**
*	Task Type.
*/
class Task {
private:
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The return type.
	*	Note: error means void.
	*/
	AType m_returnType;
	/**
	*	The parameters.
	*/
	Variable[] m_parameters;
	/**
	*	The variables.
	*/
	Variable[string] m_variables;
	/**
	*	The attributes.
	*/
	string[] m_attributes;
public:
	/**
	*	Creates a new instance of Task.
	*	Params:
	*		name =					The name of the task.
	*		returnType =			The return type of the task.
	*		parameters =			The parameters.
	*		attributes =			The attributes.
	*		inheritedVariables =	The inheritedVariables from parents.
	*/
	this(string name, AType returnType, Variable[] parameters, string[] attributes, Variable[string] inheritedVariables) {
		m_name = name;
		m_returnType = returnType;
		m_parameters = parameters;
		m_attributes = attributes;
		foreach (v; inheritedVariables.values)
			addVar(v);
		foreach (param; parameters)
			addVar(param);
	}
	
	@property {
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
		
		/**
		*	Gets the return type.
		*/
		AType returnType() { return m_returnType; }
		
		/**
		*	Gets the parameters.
		*/
		Variable[] parameters() { return m_parameters; }
		
		/**
		*	Gets the variables.
		*/
		Variable[string] variables() { return m_variables; }
		
		/**
		*	Gets the attributes.
		*/
		string[] attributes() { return m_attributes; }
	}
	
	/**
	*	Adds a variable to the task.
	*	Params:
	*		var =	The variable to add.
	*/
	void addVar(Variable var) {
		m_variables[var.name] = var;
	}
	
	/**
	*	Prints the task.
	*	Params:
	*		tabs =	The amount of tabs to print.
	*/
	void print(string tabs) {
		import std.stdio : writeln, writefln;
		writefln("%sTask:", tabs);
		writefln("%s\tName: %s", tabs, m_name);
		writefln("%s\tReturn Type: %s", tabs, m_returnType);
		
		if (m_parameters) {
			writefln("%s\tParameters:", tabs);
			foreach (var; m_parameters) {
				var.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writefln("%s\tParameters: N/A", tabs);
			
		if (m_variables) {
			writefln("%s\tVariables:", tabs);
			foreach (var; m_variables) {
				var.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writefln("%s\tParameters: N/A", tabs);
			
		if (m_attributes) {
			writefln("%s\tAttributes:", tabs);
			foreach (attr; m_attributes) {
				writefln("%s\t\t%s", tabs, attr);
			}
		}
		else
			writefln("%s\tAttributes: N/A", tabs);
	}
}