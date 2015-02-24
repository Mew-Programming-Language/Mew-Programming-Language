/*
	Mew types that are parsable.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.parsingtypes;

// Std Imports
import std.string : format;

// Mew Imports
import parser.tokenizer : AType, ATypeDeclaration;

/**
*	Enumeration for first modifier access.
*/
enum ModifierAccess1 {
	_public, // write = all, read = all
	_protected, // write = self + child, read = self + child
	_private, // write = self, read = self
	_personal // write = self, read = all
}

/**
*	Enumeration for secondary modifier access.
*/
enum ModifierAccess2 {
	none, // dependending on ModifierAccess1 only
	_const, // write = none (set once)
	_immutable, // write = constructor only
	_scope, // call free() if malloc() was called on it, else call destructor if existing, else attempt to free all its data
}

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
	*	UDT
	*/
	string m_udt;
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
	/**
	*	The first modifier access.
	*/
	ModifierAccess1 m_modifier1;
	/**
	*	The secondary modifier access.
	*/
	ModifierAccess2 m_modifier2;
public:
	/**
	*	Creates a new instance of Variable.
	*	Params:
	*		type =				The type.
	*		name =				The name.
	*		defaultValue =		The default value. (null for nothing.)
	*		attributes =		The attributes.
	*/
	this(AType type, string name, string defaultValue, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		m_type1 = type;
		m_declaration = ATypeDeclaration.single;
		m_name = name;
		m_defaultValue = defaultValue;
		m_attributes = attributes;
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
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
	this(ATypeDeclaration declaration, AType type1, AType type2, string name, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		m_type1 = type1;
		m_type2 = type2;
		m_declaration = declaration;
		m_name = name;
		m_defaultValue = defaultValue;
		m_attributes = attributes;
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
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
		string udt() { return m_udt; }
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
		
		/**
		*	Gets the first modifier access.
		*/
		ModifierAccess1 modifier1() { return m_modifier1; }
		
		/**
		*	Gets the second modifier access.
		*/
		ModifierAccess2 modifier2() { return m_modifier2; }
	}
	
	void setUDT(string udt) {
		m_udt = udt;
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
			writefln("%s\tUDT: %s", tabs, m_udt);
			writefln("%s\tName: %s", tabs, m_name);
			writefln("%s\tModifier 1: %s", tabs, m_modifier1);
			writefln("%s\tModifier 2: %s", tabs, m_modifier2);
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
			writefln("%s\tModifier 1: %s", tabs, m_modifier1);
			writefln("%s\tModifier 2: %s", tabs, m_modifier2);
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
	*	The initialization variables.
	*/
	Variable[string] m_initVariables;
	/**
	*	The attributes.
	*/
	string[] m_attributes;
	/**
	*	The parent.
	*/
	ParentType m_parent;
	/**
	*	The expressions
	*/
	TaskExpression[] m_expressions;
	/**
	*	The first modifier access.
	*/
	ModifierAccess1 m_modifier1;
	/**
	*	The secondary modifier access.
	*/
	ModifierAccess2 m_modifier2;
	/**
	*	The udt.
	*/
	string m_udt;
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
	this(string name, AType returnType, Variable[] parameters, string[] attributes, Variable[string] inheritedVariables, ModifierAccess1 modifier1, ModifierAccess2 modifier2, ParentType parent = null) {
		m_name = name;
		m_returnType = returnType;
		m_parameters = parameters;
		m_attributes = attributes;
		foreach (v; inheritedVariables.values)
			addVar(v, false);
		foreach (param; parameters)
			addVar(param);
		m_parent = parent;
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
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
		*	Gets the initialization variables.
		*/
		Variable[string] initVariables() { return m_initVariables; }
		
		/**
		*	Gets the attributes.
		*/
		string[] attributes() { return m_attributes; }
		
		/**
		*	Gets the expressions.
		*/
		TaskExpression[] expressions() { return m_expressions; }
		
		/**
		*	Gets the parent type.
		*/
		ParentType parent() { return m_parent; }
		
		/**
		*	Gets the first modifier access.
		*/
		ModifierAccess1 modifier1() { return m_modifier1; }
		
		/**
		*	Gets the second modifier access.
		*/
		ModifierAccess2 modifier2() { return m_modifier2; }
		
		/**
		*	Gets the udt.
		*/
		string udt() { return m_udt; }
	}
	
	/**
	*	Sets the udt.
	*/
	void setUDT(string udt) {
		m_udt = udt;
	}
	
	/**
	*	Adds a variable to the task.
	*	Params:
	*		var =		The variable to add.
	*		isInit =	Boolean determining whether the variable should be initialized as local or not.
	*	Returns: True if the variable was added, false if duplicate.
	*/
	bool addVar(Variable var, bool isInit = true) {
		if (isInit) {
			if (var.name in m_initVariables)
				return false;
			m_initVariables[var.name] = var;
		}
		m_variables[var.name] = var;
		return true;
	}
	
	/**
	*	Adds an expression to the task.
	*	Params:
	*		exp =	The expression to add.
	*/
	void addExp(TaskExpression exp) {
		m_expressions ~= exp;
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
		if (m_parent)
			writefln("%s\tParent: %s", tabs, m_parent.name);
		writefln("%s\tReturn Type: %s", tabs, m_returnType);
		writefln("%s\tModifier 1: %s", tabs, m_modifier1);
		writefln("%s\tModifier 2: %s", tabs, m_modifier2);
		
		if (m_parameters) {
			writefln("%s\tParameters:", tabs);
			foreach (var; m_parameters) {
				writefln("%s\t\t%s", tabs, var.name);
				writeln();
			}
		}
		else
			writefln("%s\tParameters: N/A", tabs);
			
		if (m_variables) {
			writefln("%s\tVariables:", tabs);
			foreach (var; m_initVariables.values) {
				var.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writefln("%s\tVariables: N/A", tabs);
			
		if (m_attributes) {
			writefln("%s\tAttributes:", tabs);
			foreach (attr; m_attributes) {
				writefln("%s\t\t%s", tabs, attr);
			}
		}
		else
			writefln("%s\tAttributes: N/A", tabs);
			
		if (m_expressions) {
			writefln("%s\tExpressions:", tabs);
			foreach (exp; m_expressions) {
				writefln("%s\t\t%s", tabs, exp.toString());
			}
		}
		else
			writefln("%s\tExpressions: N/A", tabs);
	}
}

/**
*	Parent type.
*/
class ParentType {
private:
	/**
	*	Boolean determining whether the parent is a struct.
	*/
	bool m_isStruct;
protected:
	/**
	*	The name of the parent.
	*/
	string m_name;
public:
	/**
	*	Creates a new instance of ParentType.
	*	Params:
	*		isStruct =	Set to true for struct, false for class.
	*/
	this(bool isStruct) {
		m_isStruct = isStruct;
	}
	
	@property {
		/**
		*	Gets a boolean determining whether the parent is a struct or not.
		*/
		bool isStruct() { return m_isStruct; }
		
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
	}
}

/**
*	A struct variable.
*	Note: A struct variable is the same as a normal variable, except for that it has alignment information.
*/
class StructVariable : Variable {
private:
	/**
	*	The alignment.
	*/
	size_t m_alignment;
public:
	/**
	*	Creates a new instance of StructVariable.
	*	Params:
	*		type =				The type.
	*		name =				The name.
	*		defaultValue =		The default value. (null for nothing.)
	*		attributes =		The attributes.
	*/
	this(AType type, string name, string defaultValue, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		super(type, name, defaultValue, attributes, modifier1, modifier2);
	}
	
	/**
	*	Creates a new instance of StructVariable.
	*	Params:
	*		declaration = 	The declaration.
	*		type1 =			The first type.
	*		type2 =			The second type.
	*		name =			The name.
	*		attributes =	The attributes.
	*/
	this(ATypeDeclaration declaration, AType type1, AType type2, string name, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		super(declaration, type1, type2, name, attributes, modifier1, modifier2);
	}
	
	@property {
		/**
		*	Gets the alignment.
		*/
		size_t alignment() { return m_alignment; }
		
		/**
		*	Sets the alignment in bytes.
		*	Note: Set through the @align attribute.
		*	Ex:   @align(10) << places 10 empty bytes after the variable.
		*/
		void alignment(size_t newAlignment) {
			m_alignment = newAlignment;
		}
	}
}

/**
*	Struct Type
*/
class Struct : ParentType {
private:
	/**
	*	The attributes.
	*/
	string[] m_attributes;
	/**
	*	The variables.
	*/
	Variable[string] m_variables;
	/**
	*	The child variables.
	*/
	StructVariable[string] m_childVariables;
	/**
	*	The initialization variables.
	*/
	StructVariable[] m_initVariables;
	/**
	*	The tasks.
	*/
	Task[string] m_tasks;
	/**
	*	The initialization tasks.
	*/
	Task[string] m_initTasks;
	/**
	*	The first modifier access.
	*/
	ModifierAccess1 m_modifier1;
	/**
	*	The secondary modifier access.
	*/
	ModifierAccess2 m_modifier2;
public:
	/**
	*	Creates a new instance of Struct.
	*	Params:
	*		name =					The name of the struct.
	*		attributes =			The attributes.
	*		inheritedVariables =	The inheritedVariables from parents.
	*/
	this(string name, string[] attributes, Variable[string] inheritedVariables, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		m_name = name;
		m_attributes = attributes;
		foreach (k, v; inheritedVariables) {
			if (v.modifier1 == ModifierAccess1._public ||
				v.modifier1 == ModifierAccess1._protected ||
				v.modifier1 == ModifierAccess1._personal) {
				m_variables[k] = v;
			}
		}
		
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
		super(true);
	}
	
	@property {
		/**
		*	Gets the variables.
		*/
		Variable[string] variables() { return m_variables; }
			/**
		*	Gets the child variables.
		*/
		StructVariable[string] childVariables() { return m_childVariables; }
		
		/**
		*	Gets the initialization variables.
		*/
		StructVariable[] initVariables() { return m_initVariables; }
		
		/**
		*	Gets the tasks.
		*/
		Task[string] tasks() { return m_tasks; }
		
		/**
		*	Gets the initialization tasks.
		*/
		Task[string] initTasks() { return m_initTasks; }
		
		/**
		*	Gets the attributes.
		*/
		string[] attributes() { return m_attributes; }
		
		/**
		*	Gets the first modifier access.
		*/
		ModifierAccess1 modifier1() { return m_modifier1; }
		
		/**
		*	Gets the second modifier access.
		*/
		ModifierAccess2 modifier2() { return m_modifier2; }
	}
	
	/**
	*	Adds a variable to the struct.
	*	Params:
	*		var =	The variable to add.
	*	Returns: True if the variable was added, false if duplicate.
	*/
	bool addVar(StructVariable var) {
		if (var.name in m_childVariables)
			return false;
		m_childVariables[var.name] = var;
		m_variables[var.name] = var;
		m_initVariables ~= var;
		return true;
	}
	
	/**
	*	Adds a task to the struct.
	*	Params:
	*		var =	The task to add.
	*	Returns: True if the task was added, false if duplicate.
	*/
	bool addTask(Task task) {
		if (task.name in m_initTasks)
			return false;
		m_tasks[task.name] = task;
		m_initTasks[task.name] = task;
		return true;
	}
	
	/**
	*	Prints the struct.
	*	Params:
	*		tabs =	The amount of tabs to print.
	*/
	void print(string tabs) {
		import std.stdio : writeln, writefln;
		writefln("%sStruct:", tabs);
		writefln("%s\tName: %s", tabs, m_name);
		writefln("%s\tModifier 1: %s", tabs, m_modifier1);
		writefln("%s\tModifier 2: %s", tabs, m_modifier2);
			
		if (m_initVariables) {
			writefln("%s\tVariables:", tabs);
			foreach (var; m_initVariables) {
				var.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writefln("%s\tVariables: N/A", tabs);
		
		if (m_initTasks) {
			writefln("%s\tTasks:", tabs);
			foreach (task; m_initTasks.values) {
				task.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writeln("\tTasks: N/A");
			
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
*	Class Type
*/
class Class : ParentType {
private:
	/**
	*	The parent.
	*/
	Class m_parent;
	/**
	*	The attributes.
	*/
	string[] m_attributes;
	/**
	*	The variables.
	*/
	Variable[string] m_variables;
	/**
	*	The initialization variables.
	*/
	Variable[string] m_initVariables;
	/**
	*	The tasks.
	*/
	Task[string] m_tasks;
	/**
	*	The initialization tasks.
	*/
	Task[string] m_initTasks;
	/**
	*	The first modifier access.
	*/
	ModifierAccess1 m_modifier1;
	/**
	*	The secondary modifier access.
	*/
	ModifierAccess2 m_modifier2;
public:
	/**
	*	Creates a new instance of Class.
	*	Params:
	*		name =					The name of the class.
	*		attributes =			The attributes.
	*		inheritedVariables =	The inheritedVariables from parents.
	*		parent =				The parent class.
	*/
	this(string name, string[] attributes, Variable[string] inheritedVariables, Class parent, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		m_name = name;
		m_attributes = attributes;
		foreach (k, v; inheritedVariables) {
			if (v.modifier1 == ModifierAccess1._public ||
				v.modifier1 == ModifierAccess1._protected ||
				v.modifier1 == ModifierAccess1._personal) {
				m_variables[k] = v;
			}
		}
		if (parent) {
			auto sup = new Variable(AType._class, "super", null, null, ModifierAccess1._private, ModifierAccess2.none);
			sup.setUDT(parent.name);
			m_variables[sup.name] = sup;
			
			foreach (k, v; parent.initVariables) {
				if (v.modifier1 == ModifierAccess1._public ||
					v.modifier1 == ModifierAccess1._protected ||
					v.modifier1 == ModifierAccess1._personal) {
					m_variables[k] = v;
				}
			}
			m_parent = parent;
		}
		
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
		super(false);
	}
	
	@property {
		/**
		*	Gets the parent.
		*/
		Class parent() { return m_parent; }
		
		/**
		*	Gets the variables.
		*/
		Variable[string] variables() { return m_variables; }
		/**
		*	Gets the initialization variables.
		*/
		Variable[string] initVariables() { return m_initVariables; }
		
		/**
		*	Gets the tasks.
		*/
		Task[string] tasks() { return m_tasks; }
		
		/**
		*	Gets the initialization tasks.
		*/
		Task[string] initTasks() { return m_initTasks; }
		
		/**
		*	Gets the attributes.
		*/
		string[] attributes() { return m_attributes; }
		
		/**
		*	Gets the first modifier access.
		*/
		ModifierAccess1 modifier1() { return m_modifier1; }
		
		/**
		*	Gets the second modifier access.
		*/
		ModifierAccess2 modifier2() { return m_modifier2; }
	}
	
	/**
	*	Adds a variable to the class.
	*	Params:
	*		var =	The variable to add.
	*	Returns: True if the variable was added, false if duplicate.
	*/
	bool addVar(Variable var) {
		if (var.name in m_initVariables)
			return false;
		m_initVariables[var.name] = var;
		m_variables[var.name] = var;
		return true;
	}
	
	/**
	*	Adds a task to the class.
	*	Params:
	*		var =	The task to add.
	*	Returns: True if the task was added, false if duplicate.
	*/
	bool addTask(Task task) {
		if (task.name in m_initTasks)
			return false;
		m_tasks[task.name] = task;
		m_initTasks[task.name] = task;
		return true;
	}
	
	/**
	*	Prints the class.
	*	Params:
	*		tabs =	The amount of tabs to print.
	*/
	void print(string tabs) {
		import std.stdio : writeln, writefln;
		writefln("%sClass:", tabs);
		writefln("%s\tName: %s", tabs, m_name);
		if (m_parent)
			writefln("%s\tParent: %s", tabs, m_parent.name);
		else
			writefln("%s\tParent: N/A", tabs);
		writefln("%s\tModifier 1: %s", tabs, m_modifier1);
		writefln("%s\tModifier 2: %s", tabs, m_modifier2);
			
		if (m_initVariables) {
			writefln("%s\tVariables:", tabs);
			foreach (var; m_initVariables) {
				var.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writefln("%s\tVariables: N/A", tabs);
		
		if (m_initTasks) {
			writefln("%s\tTasks:", tabs);
			foreach (task; m_initTasks.values) {
				task.print(tabs ~ "\t\t");
				writeln();
			}
		}
		else
			writeln("\tTasks: N/A");
			
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
*	Enumeration for expression types.
*/
enum ExpressionType {
	LOR,
	LORCall,
	LO
}

/**
*	Task expression.
*/
class TaskExpression {
private:
	/**
	*	The type of the expression.
	*/
	ExpressionType m_type;
public:
	/**
	*	Creates a new instance of TaskExpression.
	*	Params:
	*		type =	The type of the expression.
	*/
	this(ExpressionType type) {
		m_type = type;
	}
	
	@property {
		/**
		*	Gets the expression type.
		*/
		ExpressionType expressionType() { return m_type; }
	}
}

/**
*	LEFT OPERATOR RIGHT Expression.
*/
class LORExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression; // LEFT OP RIGHT ex. a = b
public:
	/**
	*	Creates a new instance of LORExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression) {
		m_expression = expression;
	
		super(ExpressionType.LOR);
	}
	
	@property {
		/**
		*	Gets the expression.
		*/
		string[] expression() { return m_expression; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		return format("%s %s %s", m_expression[0], m_expression[1], m_expression[2]);
	}
}

/**
*	LEFT OPERATOR RIGHT Call Expression.
*/
class LORCallExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression; // LEFT OP RIGHT ex. a = b()
	/**
	*	The parameters.
	*/
	string[] m_params; // PARAMETERS
public:
	/**
	*	Creates a new instance of LORExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression, string[] params) {
		m_expression = expression;
		m_params = params;

		super(ExpressionType.LORCall);
	}
	
	@property {
		/**
		*	Gets the expression.
		*/
		string[] expression() { return m_expression; }
		
		/**
		*	Gets the parameters.
		*/
		string[] params() { return m_params; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		import std.array : join;
		if (m_params)
			return format("%s %s %s(%s)", m_expression[0], m_expression[1], m_expression[2], join(m_params, ","));
		else
			return format("%s %s %s()", m_expression[0], m_expression[1], m_expression[2]);
	}
}

/**
*	LEFT OPERATOR expression.
*/
class LOExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression; // LEFT OP ex. a++
public:
	/**
	*	Creates a new instance of LOExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression) {
		m_expression = expression;
	
		super(ExpressionType.LO);
	}
	
	@property {
		string[] expression() { return m_expression; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		return format("%s%s", m_expression[0], m_expression[1]);
	}
}