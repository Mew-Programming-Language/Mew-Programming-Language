/*
	This module is for C locations.
	
	Authors:
		Jacob Jensen / Bauss
*/
module cparser.location;

/**
*	Enumerator of locations.
*/
enum Location {
	/**
	*	The location is global code.
	*/
	source,
	/**
	*	The location is a struct.
	*/
	_struct,
	/**
	* The location is a function body.
	*/
	func
}

/**
*	Checks whether the location is valid for a specific prefix.
*	Params:
*		loc =		The location of the prefix.
*		pref =		The prefix to validate.
*	Returns: True if the location is valid, false otherwise.
*/
bool validLocation(Location loc, string pref) {
	switch (pref) {
		case "var":
			return loc != Location.func; // variables in funcs are declared as expressions
		case "func":
			return loc == Location.source;
		case "import":
			return loc == Location.source;
		case "exp":
			return loc == Location.func;
		case "struct":
			return loc == Location.source;
		default:
			return false;
	}
}