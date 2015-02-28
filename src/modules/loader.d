/*
	Module loading handlers.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module modules.loader;

// Mew Imports
import csettings;
import modules.naming;

/**
*	Loads all the modules.
*	Returns: True if the modules were loaded and the main module was found.
*/
bool loadModules() {
	if (useOnlineSource) {
		// check version
		// download if not matching or files are missing
	}
	
	foreach (path; sourceFolders) { // ~ autoSourceFolders) {
		loadModulesByPath(path);
	}
	
	// Checks whether the main module exists
	return getModuleByName("main") !is null;
}