/*
	This module is for parsing mew variables.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.variableparser;

// Mew Imports
import errors.report;
import parser.parsingtypes;
import parser.tokenizer;
import parser.namevalidator;

/**
*	Variable parser.
*/
class VariableParser(T) {
//if (typeid(T) == typeid(Variable)) {
private:
	/**
	*	The variable.
	*/
	T m_var;
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
		T var() { return m_var; }
	}
	
	/**
	*	Parses a variable.
	*	This calls parse2() underneath.
	*	Params:
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		line =				The current line text.
	*		attributes =		The attributes.
	*		modifier1 =			The first modifier access.
	*		modifier2 =			The second modifier access.
	*		structs =			The struct types.
	*		classes =			The class types.
	*		enums =				The enum types.
	*	Returns: True if the variable was parsed successfully, otherwise false.
	*/
	bool parse(string fileName, ref size_t lineNumber, string line, string[] attributes,
		ModifierAccess1 modifier1, ModifierAccess2 modifier2,
		string[] structs, string[] classes, string[] enums) {
		auto tokenized = tokenizeVariable(fileName, lineNumber, line, structs, classes, enums);
		return parse2(tokenized, fileName, lineNumber, line, attributes, modifier1, modifier2);
	}
	
	/**
	*	Parses a variable that has already been tokenized.
	*	Params:
	*		tokenized =		The tokenized variable.
	*		fileName =			The file name.
	*		lineNumber =		(ref) The current line.
	*		line =				The current line text.
	*		attributes =	The attributes.
	*		modifier1 =			The first modifier access.
	*		modifier2 =			The second modifier access.
	*	Returns: True if the variable was parsed successfully, otherwise false.
	*/
	bool parse2(ATypeTuple tokenized, string fileName, ref size_t lineNumber, string line, string[] attributes,
		ModifierAccess1 modifier1, ModifierAccess2 modifier2) {
		if (tokenized[0] != AType.error) {
			if (tokenized[2] == ATypeDeclaration.single) {
				// POD / UDT
				auto type = tokenized[0];
				string name = tokenized[3];
				if (!validName(name)) {
					reportError(fileName, lineNumber, "Invalid Name", "Invalid variable name. Make sure it's A-Z and doesn't conflic with keywords.");
					return false;
				}
				string value = tokenized[4];
				
				m_var = new T(type, name, value, attributes, modifier1, modifier2);
				if (tokenized[5])
					m_var.setUDT(tokenized[5]);
				return true;
			}
			else {
				// ADT
				auto declaration = tokenized[2];
				auto type1 = tokenized[0];
				auto type2 = tokenized[1];
				string name = tokenized[3];
				if (!validName(name)) {
					reportError(fileName, lineNumber, "Invalid Name", "Invalid variable name. Make sure it's A-Z and doesn't conflic with keywords.");
					return false;
				}
					
				m_var = new T(declaration, type1, type2, name, attributes, modifier1, modifier2);
				if (tokenized[5])
					m_var.setUDT(tokenized[5]);
				return true;
			}
		}
		return false;
	}
}