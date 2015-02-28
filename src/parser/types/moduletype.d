/*
	Mew module type module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.moduletype;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
import parser.types.variabletype;
import parser.types.tasktype;
import parser.types.structtype;
import parser.types.classtype;


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
	*	The C header includes.
	*/
	string[] m_includes;
	/**
	*	The C externs.
	*/
	string[] m_cextern;
	/**
	*	The global variables.
	*/
	Variable[string] m_globalVariables;
	/**
	*	The init variables.
	*/
	Variable[string] m_initVariables;
	/**
	*	The global tasks.
	*/
	Task[string] m_globalTasks;
	/**
	*	The init tasks.
	*/
	Task[string] m_initTasks;
	/**
	*	The structs.
	*/
	Struct[string] m_structs;
	/**
	*	The init structs.
	*/
	Struct[string] m_initStructs;
	/**
	*	The classes.
	*/
	Class[string] m_classes;
	/**
	*	The init classes.
	*/
	Class[string] m_initClasses;
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
		*	Gets the C header includes.
		*/
		string[] includes() { return m_includes; }
		
		/**
		*	Gets the C externs.
		*/
		string[] cextern() { return m_cextern; }
		
		/**
		*	Gets the global variables.
		*/
		Variable[string] globalVariables() { return m_globalVariables; }
		
		/**
		*	Gets the init variables.
		*/
		Variable[string] initVariables() { return m_initVariables; }
		
		/**
		*	Gets the global tasks.
		*/
		Task[string] globalTasks() { return m_globalTasks; }
		
		/**
		*	Gets the init tasks.
		*/
		Task[string] initTasks() { return m_initTasks; }
		
		/**
		*	Gets the structs.
		*/
		Struct[string] structs() { return m_structs; }
		
		/**
		*	Gets the init structs.
		*/
		Struct[string] initStructs() { return m_initStructs; }
		
		/**
		*	Gets the classes.
		*/
		Class[string] classes() { return m_classes; }
		
		/**
		*	Gets the init classes.
		*/
		Class[string] initClasses() { return m_initClasses; }
	}
	
	/**
	*	Adds an import.
	*	Params:
	*		mod =	The module to add as an import.
	*/
	void addImport(Module mod) {
		m_imports ~= mod;
		foreach (var; mod.initVariables.values) {
			if (var.modifier1 == ModifierAccess1._public)
				m_globalVariables[var.name] = var;
		}
		foreach (task; mod.initTasks.values) {
			if (task.modifier1 == ModifierAccess1._public)
				m_globalTasks[task.name] = task;
		}
		foreach (strc; mod.initStructs.values) {
			if (strc.modifier1 == ModifierAccess1._public)
				m_structs[strc.name] = strc;
		}
		foreach (cls; mod.initClasses.values) {
			if (cls.modifier1 == ModifierAccess1._public)
				m_classes[cls.name] = cls;
		}
	}
	
	/**
	*	Adds a C header include.
	*	Params:
	*		header =	The header to include.
	*/
	void addInclude(string header) {
		m_includes ~= header;
	}
	
	/**
	*	Adds a C extern.
	*	Params:
	*		header =	The C extern.
	*/
	void addCExtern(string ext) {
		m_cextern ~= ext;
	}
	
	/**
	*	Adds a global variable.
	*	Params:
	*		var =	The variable to add.
	*	Returns: True if the variable was added, false if duplicate.
	*/
	bool addGlobalVar(Variable var) {
		if (var.name in m_initVariables)
			return false;
		m_globalVariables[var.name] = var;
		m_initVariables[var.name] = var;
		return true;
	}
	
	/**
	*	Adds a global task.
	*	Params:
	*		task =	The task to add.
	*	Returns: True if the task was added, false if duplicate.
	*/
	bool addGlobalTask(Task task) {
		if (task.name in m_initTasks)
			return false;
		m_globalTasks[task.name] = task;
		m_initTasks[task.name] = task;
		return true;
	}
	
	/**
	*	Adds a struct.
	*	Params:
	*		strc =	The struct to add.
	*	Returns: True if the struct was added, false if duplicate.
	*/	
	bool addStruct(Struct strc) {
		if (strc.name in m_initStructs)
			return false;
		m_structs[strc.name] = strc;
		m_initStructs[strc.name] = strc;
		return true;
	}
	
	/**
	*	Adds a class.
	*	Params:
	*		cls =	The class to add.
	*	Returns: True if the class was added, false if duplicate.
	*/	
	bool addClass(Class cls) {
		if (cls.name in m_classes)
			return false;
		m_classes[cls.name] = cls;
		m_initClasses[cls.name] = cls;
		return true;
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
		
		if (m_includes) {
			writeln("\tIncludes:");
			foreach (inc; m_includes) {
				writefln("\t\t%s", inc);
				writeln();
			}
		}
		else
			writeln("\tIncludes: N/A");
		
		if (m_cextern) {
			writeln("\tC-Externs:");
			foreach (ext; m_cextern) {
				writefln("\t\t%s", ext);
				writeln();
			}
		}
		else
			writeln("\tC-Externs: N/A");
			
		if (m_initVariables) {
			writeln("\tGlobal Vars:");
			foreach (var; m_initVariables) {
				var.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tGlobal Vars: N/A");
			
		if (m_initTasks) {
			writeln("\tGlobal Tasks:");
			foreach (task; m_initTasks.values) {
				task.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tGlobal Tasks: N/A");
		
		if (m_initStructs) {
			writeln("\tStructs:");
			foreach (strc; m_initStructs.values) {
				strc.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tStructs: N/A");
			
		if (m_initClasses) {
			writeln("\tClasses:");
			foreach (cls; m_initClasses.values) {
				cls.print("\t\t");
				writeln();
			}
		}
		else
			writeln("\tClasses: N/A");
	}
}