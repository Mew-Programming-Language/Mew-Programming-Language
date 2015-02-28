/*
	This module is for C structs.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.structs;

// Std Imports
import std.string : format;
import std.algorithm : filter;
import std.array;

// Mew Imports
import cparser.location;
import cparser.variables;

/**
*	The struct collection.
*/
private Struct[] _structs;

/**
*	Adds a struct to the struct collection.
*	Params:
*		strc =	The struct to add.
*/
void addStruct(Struct strc) {
	_structs ~= strc;
}

/**
*	Gets structs based on a location.
*	Params:
*		loc =		The location of the structs.
*		locName =	The name of the location.
*	Returns: The structs found at the location.
*/
auto getStructsByLocation(Location loc, string locName) {
	auto search = filter!(e => e.m_location == loc && e.m_locationName == locName)(_structs).array;
	if (!search || !search.length)
		return null;
	return search;
}

/**
*	Struct wrapper.
*/
class Struct {
private:
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The variables.
	*/
	Variable[] m_variables;
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
	*	name =			The name of the struct.
	*	location =		The location of the struct.
	*	locationName =	The name of the struct's location.
	*/
	this(string name, Location location, string locationName) {
		m_name = name;
		m_variables = getVariablesByLocation(Location._struct, m_name);
		m_location = location;
		m_locationName = locationName;
	}
	
	/**
	*	Gets the c code string of the struct.
	*/
	override string toString() {
		string[] vars;
		foreach (var; m_variables)
			vars ~= var.toSource(false);
		
		return format("struct %s {
	%s
};", m_name, join(vars, "\r\n"));
	}
}