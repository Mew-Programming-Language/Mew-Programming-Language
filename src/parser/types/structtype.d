/*
	Mew struct type module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.structtype;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
import parser.types.variabletype;
import parser.types.tasktype;

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
	this(string type, string name, string defaultValue, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		super(type, name, defaultValue, attributes, modifier1, modifier2);
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
		m_variables["this"] = new Variable(name, "this", null, null, ModifierAccess1._private, ModifierAccess2.none);
		// do value shit later ...
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