/*
	This module is for parsing C code from a mew library.
	
	Authors:
		Jacob Jensen / Bauss
	License:
		Apache License 2.0
		https://github.com/Mew-Programming-Language/Mew-Programming-Language/blob/master/LICENSE
*/
module cparser.handler;

// Std Imports
import std.algorithm : endsWith;
import std.string : splitLines, KeepTerminator;
import std.array : split, replace;
import std.conv : to;

// Mew Imports
import errors.report;
import csettings;
import cparser.location;

/**
*	Parses a .mlib file and converts it to c code.
*	Params:
*		text =	The source of a .mlib file.
*	Returns: True if the .mlib file was parsed successfully, false otherwise.
*/
bool parseMewLibary(string text) {
	size_t lineNumber;
	foreach (line; splitLines(text, KeepTerminator.no)) {
		lineNumber++;
		if (!line || !line.length)
			continue;
		auto data = split(line, " ");
		
		switch (data[0]) {
			case "def": {
				auto id = to!size_t(data[1]);
				size_t valueStart = data[0].length + data[1].length + 2;
				string value = line[valueStart .. $];
				import cparser.values;
				addValue(id, value);
				break;
			}
			
			case "var": {
				string type = replace(data[1], "|", " ");
				string name = data[2];
				auto loc = cast(Location)to!size_t(data[3]);
				if (!validLocation(loc, data[0])) {
					reportError("MLIB", lineNumber, "Location Error", "Invalid location for 'var'");
					return false;
				}
				string locName = data[4];
					
				auto id = to!size_t(data[5]);
				
				import cparser.variables;
				auto var = new Variable(type, name, id, loc, locName);
				addVariable(var);
				break;
			}
			
			case "import": {
				string name = data[1];
				bool isStdc = to!bool(data[2]);
				auto loc = cast(Location)to!size_t(data[3]);
				if (!validLocation(loc, data[0])) {
					reportError("MLIB", lineNumber, "Location Error", "Invalid location for 'import'");
					return false;
				}
				string locName = data[4];
				
				import cparser.imports;
				auto imp = new Import(name, isStdc, loc,locName);
				addImport(imp);
				break;
			}
			
			case "exp": {
				auto id = to!size_t(data[1]);
				auto loc = cast(Location)to!size_t(data[2]);
				if (!validLocation(loc, data[0])) {
					reportError("MLIB", lineNumber, "Location Error", "Invalid location for 'exp'");
					return false;
				}
				string locName = data[3];
				size_t expStart = data[0].length + data[1].length + data[2].length + data[3].length;
				string expValue = line[expStart + 4 .. $];
				
				import cparser.expressions;
				auto exp = new Expression(id, expValue, loc, locName);
				addExpression(exp);
				break;
			}
			
			case "func": {
				string ret = data[1];
				string name = data[2];
				string params = replace(data[3], "|", " ");
				//params = replace(params, ";", " ");
				auto loc = cast(Location)to!size_t(data[4]);
				if (!validLocation(loc, data[0])) {
					reportError("MLIB", lineNumber, "Location Error", "Invalid location for 'func'");
					return false;
				}
				string locName = data[5];
				
				import cparser.funcs;
				auto func = new Func(ret, name, params, loc, locName);
				addFunc(func);
				break;
			}
			
			case "struct": {
				string name = data[1];
				import std.stdio;
				auto loc = cast(Location)to!size_t(data[2]);
				if (!validLocation(loc, data[0])) {
					reportError("MLIB", lineNumber, "Location Error", "Invalid location for 'struct'");
					return false;
				}
				string locName = data[3];
				
				import cparser.structs;
				auto strc = new Struct(name, loc, locName);
				addStruct(strc);
				break;
			}
			
			case "source": {
				import cparser.imports;
				import cparser.variables;
				import cparser.structs;
				import cparser.funcs;
				
				string mname = data[1];
				string name = replace(data[1], ".", "_");
				
				import std.file : write;
				
				if (mname != "main") {
					import cparser.header;
					auto h = createHeader(name,
						getImportsByLocation(Location.source, mname),
						getVariablesByLocation(Location.source, mname),
						getStructsByLocation(Location.source, mname),
						getFuncsByLocation(Location.source, mname),
					);
					version (Windows)
						write(projectFolder ~ "\\c\\" ~ name ~ ".h", h);
					version (Posix)
						write(projectFolder ~ "/c/" ~ name ~ ".h", h);
				}
				
				import cparser.source;
				auto s = createSource(name,
					getImportsByLocation(Location.source, mname),
					getVariablesByLocation(Location.source, mname),
					getFuncsByLocation(Location.source, mname),
				);
				version (Windows)
					write(projectFolder ~ "\\c\\" ~ name ~ ".c", s);
				version (Posix)
					write(projectFolder ~ "/c/" ~ name ~ ".c", s);
				break;
			}
			
			default: break;
		}
	}
	return true;
}