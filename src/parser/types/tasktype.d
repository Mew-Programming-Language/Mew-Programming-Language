/*
	Mew types that are parsable.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.tasktype;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
import parser.types.variabletype;
import parser.types.expressions;

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
	string m_returnType;
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
	this(string name, string returnType, Variable[] parameters, string[] attributes, Variable[string] inheritedVariables, ModifierAccess1 modifier1, ModifierAccess2 modifier2, ParentType parent = null) {
		m_name = name;
		m_returnType = returnType;
		m_parameters = parameters;
		m_attributes = attributes;
		foreach (v; inheritedVariables.values)
			addVar(v, false);
		foreach (param; parameters)
			addVar(param, false);
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
		string returnType() { return m_returnType; }
		
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