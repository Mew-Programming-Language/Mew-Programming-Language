/*
	Module for handling c-compilers
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module ccompiler.compilers;

// Std Imports
import std.process;
import std.file;
import std.algorithm : endsWith;
import std.array : replace, join, split;

// Mew Imports
import ccompiler.compilerinfo;

/**
*	Collection of c compilers.
*/
private CompilerInfo[string] compilers;
/**
*	The current selected compiler.
*/
private CompilerInfo selectedCompiler;

/**
*	Loads all compilers.
*	Note: This is only initialized tcc atm.
*		  Later on it will parse compiler information from settings files.
*/
void loadCompilers() {
	auto tcc = new CompilerInfo(
		"tcc",
		"compilers\\tccx86\\tcc.exe",
		"%CMPL_EXE% -o %OUT_FILE% %FILES%"
	);
	compilers[tcc.compilerName] = tcc;
	selectedCompiler = tcc;
}

/**
*	Selects a compiler.
*	Params:
*		name =	The name of the compiler to select.
*/
void selectCompiler(string name) {
	if (name in compilers) {
		selectedCompiler = compilers[name];
	}
}

/**
*	Compiles the project through the selected c compiler.
*	Returns: an int for the error code of the c compiler. 0 for success.
*/
int compileProject() {
	import csettings;
	version (Windows)
		string cProjectFolder = projectFolder ~ "\\c";
	version (Posix)
		string cProjectFolder = projectFolder ~ "/c";
	
	version (Windows)
		string outputPath = projectFolder ~ "\\out\\" ~ outputFileName;
	version (Posix)
		string outputPath = projectFolder ~ "/out/" ~ outputFileName;
		
	string sargs = replace(selectedCompiler.compilerArgs, "%CMPL_EXE%", selectedCompiler.compilerPath);
	sargs = replace(sargs, "%OUT_FILE%", outputPath);
	string[] cfiles;
	foreach (string entry; dirEntries(cProjectFolder, SpanMode.depth)) {
		if (endsWith(entry, ".c") ||
			endsWith(entry, ".o") ||
			endsWith(entry, ".a")) {
			cfiles ~= entry;
		}
	}
	
	sargs = replace(sargs, "%FILES%", join(cfiles, " "));
	auto cPid = spawnProcess(
		split(sargs, " "),
		["foo" : "bar"], Config.newEnv,
		cast(char[])cProjectFolder
	);

	return wait(cPid);
}