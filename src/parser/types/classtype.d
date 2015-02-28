/*
	Mew class type module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.classtype;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
import parser.types.variabletype;
import parser.types.tasktype;

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
		
		m_variables["this"] = new Variable(name, "this", null, null, ModifierAccess1._private, ModifierAccess2.none);
		// do value shit later ...
		
		if (parent) {
			auto sup = new Variable(parent.name, "super", null, null, ModifierAccess1._private, ModifierAccess2.none);
			addVar(sup);
			
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