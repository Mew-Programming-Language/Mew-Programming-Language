/*
	Mew type core handler module.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module parser.types.typecore;

// Std Imports
import std.string : format;

/**
*	Enumeration for first modifier access.
*/
enum ModifierAccess1 {
	_public, // write = all, read = all
	_protected, // write = self + child, read = self + child
	_private, // write = self, read = self
	_personal // write = self, read = all
}

/**
*	Enumeration for secondary modifier access.
*/
enum ModifierAccess2 {
	none, // dependending on ModifierAccess1 only
	_const, // write = none (set once)
	_immutable, // write = constructor only
	_scope, // call free() if malloc() was called on it, else call destructor if existing, else attempt to free all its data
}

/**
*	Parent type.
*/
class ParentType {
private:
	/**
	*	Boolean determining whether the parent is a struct.
	*/
	bool m_isStruct;
protected:
	/**
	*	The name of the parent.
	*/
	string m_name;
public:
	/**
	*	Creates a new instance of ParentType.
	*	Params:
	*		isStruct =	Set to true for struct, false for class.
	*/
	this(bool isStruct) {
		m_isStruct = isStruct;
	}
	
	@property {
		/**
		*	Gets a boolean determining whether the parent is a struct or not.
		*/
		bool isStruct() { return m_isStruct; }
		
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
	}
}