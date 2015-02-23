/*
	This module is for C expressions.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.expressions;

// Std Imports
import std.algorithm : filter;
import std.array;

// Mew Imports
import cparser.location;

/**
*	The expression collection.
*/
private Expression[] _expression;

/**
*	Adds an expression to the expression collection.
*	Params:
*		exp =	The expression to add.
*/
void addExpression(Expression exp) {
	_expression ~= exp;
}

/**
*	Gets expressions based on their location.
*	Params:
*		loc =		The location of the expression.
*		locName =	The name of the expression's location.
*	Returns: The expressions found at the location.
*/
auto getExpressionsByLocation(Location loc, string locName) {
	auto search = filter!(e => e.m_location == loc && e.m_locationName == locName)(_expression).array;
	if (!search || !search.length)
		return null;
	return search;
}

/**
*	Expression wrapper.
*/
class Expression {
private:
	/**
	*	The expression id.
	*/
	size_t m_id;
	/**
	*	The expression.
	*/
	string m_exp;
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
	*	Creates a new expression.
	*	Params:
	*		id =			The id of the expression.
	*		exp =			The expression.
	*		location =		The location of the expression.
	*		locationName =	The name of the expression's location.
	*/
	this(size_t id, string exp, Location location, string locationName) {
		m_id = id;
		m_exp = exp;
		m_location = location;
		m_locationName = locationName;
	}
	
	/**
	*	Gets the c string of the expression.
	*/
	override string toString() {
		return m_exp;
	}
}