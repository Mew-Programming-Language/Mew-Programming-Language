/*
	Mew variable type module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.variabletype;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
// N/A

/**
*	Variable Type.
*/
class Variable {
private:
	/**
	*	The type.
	*/
	string m_type;
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
	this(string type, string name, string defaultValue, string[] attributes, ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		m_type = type;
		m_name = name;
		m_defaultValue = defaultValue;
		m_attributes = attributes;
		m_modifier1 = modifier1;
		m_modifier2 = modifier2;
	}
	
	@property {
		/**
		*	Gets the type.
		*/
		string type() { return m_type; }
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
	
	/**
	*	Prints the variable.
	*	Params:
	*		tabs =		The amount of tabs to print.
	*/
	void print(string tabs) {
		import std.stdio : writefln;
		
		writefln("%sVariable:", tabs);
		writefln("%s\tType: %s", tabs, m_type);
		writefln("%s\tName: %s", tabs, m_name);
		writefln("%s\tModifier 1: %s", tabs, m_modifier1);
		writefln("%s\tModifier 2: %s", tabs, m_modifier2);
		if (m_defaultValue)
			writefln("%s\tDefault Value: %s", tabs, m_defaultValue);
		else
			writefln("%s\tDefault Value: N/A", tabs);
		
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