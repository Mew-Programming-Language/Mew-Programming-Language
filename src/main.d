/*
	This is the main handler of the Mew compiler.
	
	Authors:
		Jacob Jensen / Bauss
*/
module main;

// Debug Flag for pausing the compiler.
version = DEBUG_V;

// Std Imports
import std.stdio;
import std.array : join;

// Mew Imports
import cargs;
import errors.report;

/**
*	Entry point of the Mew compiler.
*/
int main(string[] _args) {
	try {
		// Compiling it with the "MewProject" folder which is located in the same folder as the compiler.
		// MewProject is a test project for testing the language and its compilation.
		
		// Parsing the compiler arguments.
		foreach (arg; parseArguments(_args ~ ["-proj MewProject -ptypes"])) {
			if (arg)
				handleArguments(arg);
		}
		import csettings;
		if (showSettings) // Shows settings if the "-pargs" flag is passed to the compiler.
			printSettings();
		else if (!hasErrors) {
			import modules.loader;
			// Loads all the modules.
			if (!loadModules())
				reportError("Compiler", size_t.max, "Missing Module", "Main module is missing!");
			else {
				import parser.moduleparser;
				// parse main module ...
				auto mainParser = new ModuleParser("main");
				if (!mainParser.initialize("main", size_t.max, true) || hasErrors) {
					reportError("Compiler", size_t.max, "Module Initialization", "Main module couldn't be initialized!");
				}
				else {
					auto mainModule = mainParser.mod;
					if (!mainModule) {
						reportError("Compiler", size_t.max, "Module Not Found", "Main module couldn't be found!");
					}
					else {
						mainParser.parse();
						
						if (!hasErrors) {
							if (showTypes) {
								// Prints all modules + types if the "-ptypes" flag is passed to the compiler.
								printModules();
								readln();
								return 0;
							}
							else {
								// Compile shit ...
								
								import cparser.handler;
								string mlibText = "";
								if (!parseMewLibary(mlibText)) {
									//reportError("Compiler", size_t.max, "MLib Parsing", "Failed to parse the mlib!");
								}
							}
						}
					}
				}
			}
		}
	}
	catch (Throwable e) {
		// Writes exceptions to the standard error stream.
		stderr.writeln(e);
	}
	// If the debugging flag is enabled then it should pause the compiler.
	version (DEBUG_V) readln();
	
	// If there's errors it returns -1, else 0 for success.
	return hasErrors ? -1 : 0;
}