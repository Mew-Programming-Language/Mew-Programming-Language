/*
	Module for managing module names.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module modules.naming;

// Std Imports
import std.algorithm : startsWith, endsWith;
import std.array : replace, split;
import std.file;
import std.string : format;

// Mew Imports
import errors.report;

/**
*	The loaded modules.
*/
private string[string] _modules;

/**
*	Checks whether a file has a valid file name.
*	Params:
*		file =	The file to validate.
*	Returns: True if the file name is valid.
*/
private bool validFileName(string file) {
	/*return (endsWith(file, ".c") || endsWith(file, ".h") ||
		endsWith(file, ".mew") || endsWith(file, ".mlib") ||
		endsWith(file, ".lib") || endsWith(file, ".a"));*/
	return endsWith(file, ".mew"); // load other file types elsewhere and just pass them to the c compiler
}

/**
*	Loads modules by a specific path.
*	Params:
*		path =	The path to load modules by.
*/
void loadModulesByPath(string path) {
	foreach (string file; dirEntries(path, SpanMode.depth)) {
		if (!validFileName(file))
			continue; // The file name is not valid or not compatible with the compiler.
			
		auto text = readText(file);
		auto lines = split(text, "\n");
		if (!startsWith(lines[0], "module ")) { // If the module doesn't have an alias naming.
			// Creates a module alias from its name.
			auto name = replace(file, path, "");
			name = replace(name, "\\", ".");
			name = replace(name, "/", ".");
			
			auto m = getModuleByName(name);
			if (m) { // If the module is conflicting names
				reportError(file, size_t.max, "Module Exists", format("Conflicting module names. Module Alias: '%s'", name));
				continue;
			}
			
			_modules[name] = file;
		}
		else {
			// Gets the module alias
			auto name = lines[0];
			name = replace(name, "\r", "");
			name = name["module ".length .. $];
			
			auto m = getModuleByName(name);
			if (m) { // If the module is conflicting names
				reportError(file, size_t.max, "Module Exists", format("Conflicting module names. Module Alias: '%s'", name));
				continue;
			}
			
			_modules[name] = file;
		}
	}
}

/**
*	Gets a module by its name.
*	Params:
*		name =	The name of the module.
*	Returns: The file name of the module if it exists, null otherwise.
*/
string getModuleByName(string name) {
	return _modules.get(name, null);
}