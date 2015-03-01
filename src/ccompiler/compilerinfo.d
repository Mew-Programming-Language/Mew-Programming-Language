/*
	Module for c-compiler information.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module ccompiler.compilerinfo;

/**
*	C Compiler information.
*/
class CompilerInfo {
private:
	/**
	*	The compiler name.
	*/
	string m_compilerName;
	/**
	*	The compiler path.
	*/
	string m_compilerPath;
	/**
	*	The compiler arguments.
	*/
	string m_compilerArgs;
public:
	/**
	*	Creates a new instance of CompilerInfo.
	*	Params:
	*		name =	The name of the compiler.
	*		path =	The path of the compiler.
	*		args =	The default arguments of compiler.
	*/
	this(string name, string path, string args) {
		m_compilerName = name;
		m_compilerPath = path;
		m_compilerArgs = args;
	}
	
	@property {
		/**
		*	Gets the compiler name.
		*/
		string compilerName() { return m_compilerName; }
		
		/**
		*	Gets the compiler path.
		*/
		string compilerPath() { return m_compilerPath; }
		
		/**
		*	Gets the compiler arguments.
		*/
		string compilerArgs() { return m_compilerArgs; }
	}
}