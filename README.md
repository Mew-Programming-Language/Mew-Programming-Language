# Mew-Programming-Language
Mew is a programming language written in D and C compiling to native through C using the tcc compiler by default.

## Goals of Mew
* An object oriented (by choice) programming language with a strict syntax to ensure clean code and readability.
* An easy and user-friendly syntax.
* ADT's as build-in types rather than libraries.
* Dynamic arrays (Can be toggled off by using the @traditional attribute)
* Attribute definitions to allow special compilation
* Templates, Code-mixin & Conditional-compilation
* Compilation to native through C
* Full interaction with the standard C library
* Full interaction with C code
* No header/definition files -- Module based system
* Dynamoc proxy compilation (Able to use different C compilers)
* Error safety (Exception based system.) + handle all errors as much as possible.
* Exceptions should be usable by standard C code.
* Fully open-source -- Everything will be available to the public.
