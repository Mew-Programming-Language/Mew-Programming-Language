/*
	Module for handling command line arguments.
	
	Authors:
		Jacob Jensen / Bauss
*/
module cargs;

// Std Imports
import std.array : split;
import std.algorithm : count, strip, startsWith;
import std.conv : to;

/**
*	Exception thrown for invalid command line argument usage.
*/
class InvalidCArgumentsException : Throwable {
public:
	/**
		Creates a new instance of InvalidCArgumentsException.
		Params:
			msg =	The error message.
	*/
	this(string msg) {
		super(msg);
	}
}

/**
*	Command-line Argument
*/
class CArgument {
private:
	/**
	*	The name.
	*/
	string m_name;
	/**
	*	The argument values.
	*/
	string[] m_args;
	
	/**
	*	Creates a new instance of CArgument.
	*	Params:
	*		name =	The name.
	*		args =	The argument values.
	*/
	this(string name, string[] args) {
		m_name = name;
		m_args = args;
	}
public:
	@property {
		/**
		*	Gets the name.
		*/
		string name() { return m_name; }
		/**
		*	Gets the argument values.
		*/
		string[] args() { return m_args; }
	}
}

/**
*	Parses the command-line arguments.
*	Params:
*		_args =	The command-line argument.
*	Returns: The parsed arguments.
*/
auto parseArguments(string[] _args) {
	if (_args.length <= 1) // If there is no arguments passed (The first arg of _args is the executable path.)
		throw new InvalidCArgumentsException("No command line arguments passed!");
	_args = _args[1 .. $]; // Gets the correct arguments.
	CArgument[] args;
	
	// Loops through all the arguments.
	foreach (rarg; _args) {
		string arg = strip(rarg, ' ');
		size_t argc = count(arg, "-");
		
		if (argc > 1) { // If there's more than one argument in the passed argument.
			auto cargs = split(arg, "-"); // Splits the arguments by "-".
			foreach (rcarg; cargs) { // Loops all the arguments.
				string carg = strip(rcarg, ' ');
				auto argData = split(carg, " "); // Gets the argument vallues.
				if (argData.length == 1) // If there are no argument values.
					args ~= new CArgument(carg, null);
				else if (argData.length > 1) // If there are argument values.
					args ~= new CArgument(argData[0], argData[1 .. $]);
			}
		}
		else if (argc == 1 && arg[0] == '-') { // If there's only one argument passed.
			auto argData = split(arg, " "); // Gets the argument values.
			if (argData.length == 1) // If there are no argument values.
				args ~= new CArgument(arg[1 .. $], null);
			else if (argData.length > 1) // If there are argument values.
				args ~= new CArgument(argData[0][1 .. $], argData[1 .. $]);
		}
		else { // Invalid arguments passed or it failed to parse the arguments correctly.
			throw new InvalidCArgumentsException("Invalid command line arguments passed!" ~ to!string(argc));
		}
	}
	
	return args; // Returns all parsed arguments.
}

/**
*	Handles a specific argument.
*	Params:
*		arg =	The argument to handle.
*/
void handleArguments(CArgument arg) {
	import csettings;
	
	// arg.name equals the flag without "-" ex. "-out" becomes "out"
	switch (arg.name) {
		case "out": {
			if (outputFileName)
				throw new InvalidCArgumentsException("Output file already set.");
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No output file arguments found.");
			if (arg.args.length > 1)
				throw new InvalidCArgumentsException("Cannot have multiple output file names.");
			outputFileName = arg.args[0];
			break;
		}
		case "proj": {
			if (projectFolder)
				throw new InvalidCArgumentsException("Project folder already set.");
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No project folder found.");
			if (arg.args.length > 1)
				throw new InvalidCArgumentsException("Cannot have multiple project folders.");
			projectFolder = arg.args[0];
			version (Windows)
				sourceFolders ~= projectFolder ~ "\\src";
			version (Posix)
				sourceFolders ~= projectFolder ~ "/src";
			break;
		}
		case "src": {
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No source path arguments found.");
			if (arg.args.length > 1)
				throw new InvalidCArgumentsException("Cannot parse multiple source paths.");
			sourceFolders ~= arg.args[0];
			break;
		}
		case "unittest": {
			if (arg.args)
				throw new InvalidCArgumentsException("-unittest takes no arguments!");
			runUnitTests = true;
			break;
		}
		case "version": {
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No version arguments found.");
			if (arg.args.length > 1)
				throw new InvalidCArgumentsException("Cannot pass multiple versions at once.");
			versions ~= arg.args[0];
			break;
		}
		case "format": {
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No format arguments found.");
			if (arg.args.length > 1)
				throw new InvalidCArgumentsException("Cannot have multiple output formats.");
			switch (arg.args[0]) {
				case "x86":
				case "32":
					outputFormat = OSFormat.x86;
					break;
				case "x64":
				case "64":
					outputFormat = OSFormat.x64;
					break;
				default:
					throw new InvalidCArgumentsException("Invalid argument for output format.");
			}
			break;
		}
		case "os": {
			if (arg.args.length == 0)
				throw new InvalidCArgumentsException("No online source arguments found.");
			if (arg.args.length != 2)
				throw new InvalidCArgumentsException("Invalid argument for -os.");
			useOnlineSource = true;
			onlineSourceProject = arg.args[0];
			onlineSourcePassword = arg.args[1];
			break;
		}
		case "pargs": {
			if (arg.args)
				throw new InvalidCArgumentsException("-pargs takes no arguments!");
			showSettings = true;
			break;
		}
		case "ptypes": {
			if (arg.args)
				throw new InvalidCArgumentsException("-ptypes takes no arguments!");
			showTypes = true;
			break;
		}
		
		default:
			throw new InvalidCArgumentsException("Invalid arguments passed.");
			break;
	}
}