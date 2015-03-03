module parser.taskhandlers;

/**
*	Mixin template for return statement.
*/
mixin template ReturnStatement() {
	/**
	*	Handling the return statement.
	*/
	bool handleReturnStatement() {
		scope auto tokenized = tokenizeReturn(fileName, lineNumber, line);
		string varName = tokenized[0];
		if (!varName)
			return true;
		if (varName !in task.variables) {
			reportError(fileName, lineNumber, "Invalid Return", format("'%s' is not an accessible variable.", varName));
			return false;
		}
					
		auto var = task.variables[varName];
		if (!var) {
			reportError(fileName, lineNumber, "Invalid Return", format("'%s' does not have a compiler instance.", varName));
			return false;
		}
					
		if (var.type != m_task.returnType) {
			string rType = (m_task.returnType ? m_task.returnType : "void");
			reportError(fileName, lineNumber, "Invalid Return", format("'%s' is not type of '%s'.", varName, rType));
			return false;
		}
					
		foundReturnStatement = true;
		m_task.addExp(new ReturnExpression(varName));
		return true;
	}
}

/**
*	Mixin template for if statement.
*/
mixin template IfStatement() {
	/**
	*	Handling the if statement.
	*/
	void handleIfStatement() {
		import parser.ifparser;
		scope auto ifParser = new IfParser(m_task, lineSplit[0] == "elif");
		ifParser.parse(
			fileName, lineNumber, source, attributes, aliases,
			mod.globalVariables,
			mod.globalTasks,
			mod,
			modifier1, modifier2,
			isConstructor,
			parent
		);
	}
}

/**
*	Mixin template for else statement.
*/
mixin template ElseStatement() {
	/**
	*	Handling the else statement.
	*/
	void handleElseStatement() {
		import parser.elseparser;
		scope auto elseParser = new ElseParser(m_task);
		elseParser.parse(
			fileName, lineNumber, source, attributes, aliases,
			mod.globalVariables,
			mod.globalTasks,
			mod,
			modifier1, modifier2,
			isConstructor,
			parent
		);
	}
}

/**
*	Mixin template for expression statements.
*/
mixin template ExpStatement() {
	/**
	*	Handling the expression.
	*/
	bool handleExpStatement() {
		size_t cline = lineNumber;
			
		// parse instructions ...
		auto expression = tokenizeExpression3!false(fileName, lineNumber, line);
		if (!expression[0]) {
			if (expression[3]) // isCall
				return true;
			expression = tokenizeExpression2(fileName, lineNumber, line);
			if (!expression[1]) {
				// VARIABLE
				import parser.variableparser;
				scope auto variableParser = new VariableParser!Variable;
				if (variableParser.parse(fileName, lineNumber, line, null, ModifierAccess1._private, ModifierAccess2.none, mod.structs.keys ~ mod.cextern, mod.classes.keys, null) && variableParser.var) {
					if (!m_task.addVar(variableParser.var))
						reportError(fileName, cline, "Duplicate", "Variable name conflicting with an earlier local variable.");
				}
			}
			else {
				// LEFT_HAND_OP ex. a++
				handleLOExpression(m_task, fileName, lineNumber, [expression[0], expression[1]], mod);
			}
		}
		else {
			// LEFT_HAND OP RIGHT_HAND ex. a += b
			if (expression[3]) // isCall
				handleLORCallExpression(m_task, fileName, lineNumber, [expression[0], expression[1], expression[2]], expression[4], mod);
			else
				handleLORVariableExpression(m_task, fileName, lineNumber, [expression[0], expression[1], expression[2]], mod);
		}
		return true;
	}
}