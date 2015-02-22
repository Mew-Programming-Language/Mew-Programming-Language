/*
	This module is for parsing mew variables.
	
	Authors:
		Jacob Jensen / Bauss
*/
module parser.variableparser;

// Mew Imports
import errors.report;
import parser.parsingtypes;
import parser.tokenizer;

/**
*	Variable parser.
*/
class VariableParser {
private:
	/**
	*	The variable.
	*/
	Variable m_var;
public:
	/**
	*	Creates a new instance of VariableParser.
	*/
	this() {
	
	}
	
	@property {
		/**
		*	Gets the variable.
		*/
		Variable var() { return m_var; }
	}
	
	/**
	*	Parses a variable.
	*	This calls parse2() underneath.
	*	Params:
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		line =				The current line text.
	*		attributes =		The attributes.
	*	Returns: True if the variable was parsed successfully, otherwise false.
	*/
	bool parse(string fileName, ref size_t lineNumber, string line, string[] attributes) {
		auto tokenized = tokenizeVariable(fileName, lineNumber, line);
		return parse2(tokenized, attributes);
	}
	
	/**
	*	Parses a variable that has already been tokenized.
	*	Params:
	*		tokenized =		The tokenized variable.
	*		attributes =	The attributes.
	*	Returns: True if the variable was parsed successfully, otherwise false.
	*/
	bool parse2(ATypeTuple tokenized, string[] attributes) {
		if (tokenized[0] != AType.error) {
			if (tokenized[2] == ATypeDeclaration.single) {
				// POD / UDT
				auto type = tokenized[0];
				string name = tokenized[3];
				string value = tokenized[4];
				
				m_var = new Variable(type, name, value, attributes);
				return true;
			}
			else {
				// ADT
				auto declaration = tokenized[2];
				auto type1 = tokenized[0];
				auto type2 = tokenized[1];
				string name = tokenized[3];
							
				m_var = new Variable(declaration, type1, type2, name, attributes);
				return true;
			}
		}
		return false;
	}
}