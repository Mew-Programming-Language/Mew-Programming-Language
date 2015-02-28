/*
	This module is for C variables.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.variables;

// Std Imports
import std.string : format;
import std.algorithm : filter;
import std.array;

// Mew Imports
import cparser.location;

/**
*	The variable collection.
*/
private Variable[] _variables;

/**
*	Adds a variable to the variable collection.
*	Params:
*		var =	The variable to add.
*/
void addVariable(Variable var) {
	_variables ~= var;
}

/**
*	Gets variables based on its location.
*	Params:
*		loc =		The location of the variables.
*		locName =	The name of the location.
*	Returns: The variables placed at the location.
*/
auto getVariablesByLocation(Location loc, string locName) {
	auto search = filter!(e => e.m_location == loc && e.m_locationName == locName)(_variables).array;
	if (!search || !search.length)
		return null;
	return search;
}

/**
*	Variable wrapper.
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
	*	The value.
	*/
	string m_value;
	/**
	*	The location.
	*/
	Location m_location;
	/**
	*	The location name.
	*/
	string m_locationName;
public:
	/**
	*	Creates a new variable.
	*	Params:
	*		name =			The name of the variable.
	*		value =			The value id of the variable.
	*		location =		The location of the variable.
	*		locationName = 	The name of the variable's location.
	*/
	this(string type, string name, size_t value, Location location, string locationName) {
		m_type = type;
		m_name = name;
		if (value != 0) {
			import cparser.values;
			m_value = getValue(value);
		}
		m_location = location;
		m_locationName = locationName;
	}
	
	/**
	*	Gets the c source string of the variable.
	*	Params:
	*		useValue =	Boolean determining whether it should write the value to the variable.
	*	Returns: The c source string.
	*/
	string toSource(bool useValue = true) {
		if (useValue && m_value)
			return format("%s %s = %s;", m_type, m_name, m_value);
		else
			return format("%s %s;", m_type, m_name);
	}
	
	/**
	*	Gets the c header string of the variable.
	*	Params:
	*		useExtern =	Boolean determining whether it should write the variable as extern.
	*	Returns: The c header string.
	*/
	string toHeader(bool useExtern = true) {
		if (useExtern)
			return format("extern %s", toSource(false));
		else
			return toSource(false);
	}
}