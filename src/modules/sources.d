/*
	Module for managing module sources.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module modules.sources;

// Std Imports
import std.file : readText;
import std.algorithm : startsWith;
import std.array : join, split, replace;

// Mew Imports
import modules.naming;

/**
*	The loaded modules.
*/
private string[string] _modules;

/**
*	Loads the source of a module by its name.
*	Params:
*		name =	The name of the module.
*	Returns: True if the source was loaded, false otherwise.
*/
bool loadSourceByName(string name) {
	auto moduleFile = getModuleByName(name);
	if (!moduleFile) // The module does not exist.
		return false;

	auto source = getSourceByName(name);
	if (source) // The source was already loaded once.
		return true;
	
	auto text = readText(moduleFile);
	text = replace(text, "\r", "");
	text = replace(text, "\0", "");
	scope auto lines = split(text, "\n");
	text = join(lines, "\n");
	/*if (startsWith(lines[0], "module ")) { // If the module has a module alias strip it away
		text = join(lines[1 .. $], "\n");
	}
	else { // Else just take the whole text
		
	}*/
	_modules[name] = text;
	return true;
}

/**
*	Gets a source by module name.
*	Params:
*		name =	The name of the module.
*	Returns: The source of the module if it exists, null otherwise.
*/
string getSourceByName(string name) {
	return _modules.get(name, null);
}