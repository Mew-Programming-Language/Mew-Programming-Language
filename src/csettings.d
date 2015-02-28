/*
	Module for managing compiler settings.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/BaussProjects/Mew-Programming-Language/blob/master/LICENSE
*/
module csettings;

/**
*	The OS format's available.
*/
enum OSFormat {
	x86, // 32 bit
	x64 // 64 bit
}

// Main Project Settings
/**
*	The output file name.
*/
string outputFileName;
string projectFolder;
version (Posix) {
	/**
	*	The source folders.
	*/
	string[] sourceFolders = ["lib/orchid"];
}
version (Windows) {
	/**
	*	The source folders.
	*/
	string[] sourceFolders = ["lib\\orchid"];
}

// Compiler Settings
version (Posix) {
	/**
	*	The automatic source folders.
	*/
	string[] autoSourceFolders = ["lib/orchid_a"];
}
version (Windows) {
	/**
	*	The automatic source folders.
	*/
	string[] autoSourceFolders = ["lib\\orchid_a"];
}

// Misc Settings
/**
*	Flag for unit tests.
*/
bool runUnitTests = false;
/**
*	Flag for printing settings.
*/
bool showSettings = false;
/**
*	Flag for printing types.
*/
bool showTypes = false;
/**
*	Flag for creating .mlib file in output folder.
*/
bool createMewLibrary = false;

// Version Settings
/**
*	Versions.
*/
string[] versions;

version (X86) {
	/**
	*	The output format.
	*/
	OSFormat outputFormat = OSFormat.x86;
}
version (X86_64) {
	/**
	*	The output format.
	*/
	OSFormat outputFormat = OSFormat.x64;
}

// Online Settings
/**
*	Flag for online source.
*/
bool useOnlineSource = false;
/**
*	Online source project name.
*/
string onlineSourceProject;
/**
*	Online source password.
*/
string onlineSourcePassword;

/**
*	Prints the settings.
*/
void printSettings() {
	import std.stdio : writeln, writefln;
	writefln("Output File Name: '%s'", outputFileName);
	writefln("Project Folder: '%s'", projectFolder);
	writeln("Source Folders:");
	writeln(sourceFolders);
	writeln("Auto Source Folders:");
	writeln(autoSourceFolders);
	writefln("Unit Testing: %s", runUnitTests);
	writefln("OS Format: %s", outputFormat);
	writefln("Online Source: %s", useOnlineSource);
	if (useOnlineSource) {
		writefln("Online Source Project: '%s'", onlineSourceProject);
		writefln("Online Source Password: '%s'", onlineSourcePassword);
	}
	if (versions) {
		writeln("Versions:");
		writeln(versions);
	}
}