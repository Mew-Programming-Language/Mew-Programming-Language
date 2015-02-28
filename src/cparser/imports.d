/*
	This module is for C imports (includes).
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.imports;

// Std Imports
import std.string : format;
import std.algorithm : filter;
import std.array;

// Mew Imports
import cparser.location;

/**
*	The import collection.
*/
private Import[] _imports;

/**
*	Adds an import to the collection.
*	Params:
*		imp =	The import to add.
*/
void addImport(Import imp) {
	_imports ~= imp;
}

/**
*	Gets imports based on their location.
*	Params:
*		loc =	The location of the imports.
*		locName =	The name of the location.
*	Returns: The imports found at the location.
*/
auto getImportsByLocation(Location loc, string locName) {
	auto search = filter!(e => e.m_location == loc && e.m_locationName == locName)(_imports).array;
	if (!search || !search.length)
		return null;
	return search;
}

/**
*	Import wrapper.
*/
class Import {
private:
	/**
	*	The name of the import.
	*/
	string m_name;
	/**
	*	Boolean determining whether the import is a standard c import or not.
	*/
	bool m_isStdc;
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
	*	Creates a new import.
	*	Params:
	*		name =			The name of the import.
	*		isStdc = 		Boolean determining whether it's a standard c import or not.
	*		location = 		The location of the import.
	*		locationName =	The name of the import's location.
	*/
	this(string name, bool isStdc, Location location, string locationName) {
		m_name = name;
		m_isStdc = isStdc;
		m_location = location;
		m_locationName = locationName;
	}
	
	/**
	*	Gets the c code string of the import.
	*	Returns: The c code string.
	*/
	override string toString() {
		if (m_isStdc)
			return format("#include <%s.h>", replace(m_name, ".", "_"));
		else
			return format("#include \"%s.h\"", replace(m_name, ".", "_"));
	}
}