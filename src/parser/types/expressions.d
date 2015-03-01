/*
	Mew expression type module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.expressions;

// Std Imports
import std.string : format;

// Mew Imports
import parser.types.typecore;

// Type Related Imports
import parser.types.variabletype;

/**
*	Enumeration for expression types.
*/
enum ExpressionType {
	LOR,
	LORCall,
	LO,
	RET
}

/**
*	Task expression.
*/
class TaskExpression {
private:
	/**
	*	The type of the expression.
	*/
	ExpressionType m_type;
public:
	/**
	*	Creates a new instance of TaskExpression.
	*	Params:
	*		type =	The type of the expression.
	*/
	this(ExpressionType type) {
		m_type = type;
	}
	
	@property {
		/**
		*	Gets the expression type.
		*/
		ExpressionType expressionType() { return m_type; }
	}
}

/**
*	LEFT OPERATOR RIGHT Expression.
*/
class LORExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression;
public:
	/**
	*	Creates a new instance of LORExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression) {
		m_expression = expression;
	
		super(ExpressionType.LOR);
	}
	
	@property {
		/**
		*	Gets the expression.
		*/
		string[] expressions() { return m_expression; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		return format("%s %s %s;", m_expression[0], m_expression[1], m_expression[2]);
	}
}

/**
*	LEFT OPERATOR RIGHT Call Expression.
*/
class LORCallExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression; // LEFT OP RIGHT ex. a = b()
	/**
	*	The parameters.
	*/
	string[] m_params; // PARAMETERS
public:
	/**
	*	Creates a new instance of LORExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression, string[] params) {
		m_expression = expression;
		m_params = params;

		super(ExpressionType.LORCall);
	}
	
	@property {
		/**
		*	Gets the expression.
		*/
		string[] expressions() { return m_expression; }
		
		/**
		*	Gets the parameters.
		*/
		string[] params() { return m_params; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		import std.array : join;
		if (m_params)
			return format("%s %s %s(%s);", m_expression[0], m_expression[1], m_expression[2], join(m_params, ","));
		else
			return format("%s %s %s();", m_expression[0], m_expression[1], m_expression[2]);
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	string toString(string customParams) {
		import std.array : join;
		if (m_params)
			return format("%s %s %s(%s,%s);", m_expression[0], m_expression[1], m_expression[2], customParams, join(m_params, ","));
		else
			return format("%s %s %s(%s);", m_expression[0], m_expression[1], m_expression[2], customParams);
	}
}

/**
*	LEFT OPERATOR expression.
*/
class LOExpression : TaskExpression {
private:
	/**
	*	The expression.
	*/
	string[] m_expression; // LEFT OP ex. a++
public:
	/**
	*	Creates a new instance of LOExpression.
	*	Params:
	*		expression =	The expression.
	*/
	this(string[] expression) {
		m_expression = expression;
	
		super(ExpressionType.LO);
	}
	
	@property {
		string[] expressions() { return m_expression; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		return format("%s%s;", m_expression[0], m_expression[1]);
	}
}

/**
*	Return expression
*/
class ReturnExpression : TaskExpression {
private:
	/**
	*	The variable to return.
	*/
	string m_return;
public:
	/**
	*	Creates a new instance of ReturnExpression.
	*	Params:
	*		ret =	The return variable.
	*/
	this(string ret) {
		m_return = ret;
	
		super(ExpressionType.RET);
	}
	
	@property {
		string ret() { return m_return; }
	}
	
	/**
	*	Gets a string equivalent to the expression.
	*/
	override string toString() {
		return format("return %s;", m_return);
	}
}