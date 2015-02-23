/*
	This module is for C functions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.funcs;

// Std Imports
import std.string : format;
import std.algorithm : filter;
import std.array;

// Mew Imports
import cparser.location;
import cparser.expressions;

/**
*	The collection of functions.
*/
private Func[] _funcs;

/**
*	Adds a function to the function collection.
*	Params:
*		func =	The function to add.
*/
void addFunc(Func func) {
	_funcs ~= func;
}

/**
*	Gets functions based on their location.
*	Params:
*		loc =			The location of the functions.
*		locName =		The name of the location.
*	Returns: The functions found at the location.
*/
auto getFuncsByLocation(Location loc, string locName) {
	auto search = filter!(e => e.m_location == loc && e.m_locationName == locName)(_funcs).array;
	if (!search || !search.length)
		return null;
	return search;
}

/**
*	Function wrapper.
*/
class Func {
private:
	/**
	*	The return type.
	*/
	string m_ret;
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The parameters.
	*/
	string m_params;
	/**
	*	The expressions.
	*/
	Expression[] m_expressions;
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
	*	Creates a new function.
	*	Params:
	*		ret =				The return type of the function.
	*		name =				The name of the function.
	*		params =			The parameters of the function.
	*		location =			The location of the function.
	*		locationName = 		The name of the function's location.
	*/
	this(string ret, string name, string params, Location location, string locationName) {
		m_ret = ret;
		m_name = name;
		m_params = params;
		m_expressions = getExpressionsByLocation(Location.func, m_name);
		m_location = location;
		m_locationName = locationName;
	}
	
	/**
	*	Gets the c source string of the function.
	*	Returns: The c source string.
	*/
	string toSource() {
		string[] expressions;
		foreach (exp; m_expressions)
			expressions ~= exp.toString();
		
		return format("%s %s(%s) {
	%s
}", m_ret, m_name, m_params, join(expressions, "\r\n"));
	}
	
	/**
	*	Gets the c header string of the function.
	*	Returns: The c header string.
	*/
	string toHeader() {
		return format("%s %s(%s);", m_ret, m_name, m_params);
	}
}