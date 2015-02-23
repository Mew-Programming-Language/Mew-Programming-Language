/*
	This module is for C values.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.values;

/**
*	The value collection.
*/
private string[size_t] values;

/**
*	Adds a value to the value collection.
*	Params:
*		id =		The id of the value.
*		value =		The value.
*/
void addValue(size_t id, string value) {
	values[id] = value;
}

/**
*	Gets a value based on its id.
*	Params:
*		id =	The id of the value.
*	Returns: The value.
*/
string getValue(size_t id) {
	return values[id];
}