Premake Extension to support the [D](http://dlang.org) language

### Features ###

* Support actions: gmake, vs20xx (VisualD)
* Support all compilers; DMD, LDC, GDC
* Support combined and separate compilation

### Usage ###

Simply add:
```lua
language "D"
```
to your project definition and populate with .d files.  
C and C++ projects that include .d files will also support some of the API below. Any API tagged with (D/C/C++) works in D and C/C++ projects. Any API tagged with (C/C++) only works for .d files in C/C++ projects.

### APIs ###

* [flags](https://github.com/premake/premake-dlang/wiki/flags)
  * CodeCoverage  (D/C/C++)
  * Deprecated
  * Documentation
  * GenerateHeader
  * GenerateJSON
  * GenerateMap
  * NoBoundsCheck
  * Profile
  * Quiet
  * RetainPaths
  * SeparateCompilation
  * SymbolsLikeC
  * UnitTest (D/C/C++)
  * Verbose (D/C/C++)
  * ProfileGC (C/C++)
  * StackFrame (C/C++)
  * StackStomp (C/C++)
  * AllInst (C/C++)
  * BetterC (C/C++)
  * Main (C/C++)
  * PerformSyntaxCheckOnly (C/C++)
  * ShowCommandLine (C/C++)
  * ShowTLS (C/C++)
  * ShowGC (C/C++)
  * IgnorePragma (C/C++)
  * ShowDependencies (C/C++)
* [versionconstants](https://github.com/premake/premake-dlang/wiki/versionconstants) (D/C/C++)
* [versionlevel](https://github.com/premake/premake-dlang/wiki/versionlevel)
* [debugconstants](https://github.com/premake/premake-dlang/wiki/debugconstants) (D/C/C++)
* [debuglevel](https://github.com/premake/premake-dlang/wiki/debuglevel)
* [docdir](https://github.com/premake/premake-dlang/wiki/docdir) (D/C/C++)
* [docname](https://github.com/premake/premake-dlang/wiki/docname) (D/C/C++)
* [headerdir](https://github.com/premake/premake-dlang/wiki/headerdir) (D/C/C++)
* [headername](https://github.com/premake/premake-dlang/wiki/headername) (D/C/C++)
$todo
* dependenciesfile (C/C++)
* jsonfile (C/C++)
* stringimportpaths (C/C++)
* compilationmodel (Project,Package,File) (C/C++)
* _runtime info here_
* _target info here_
* _inlining info here_
* boundscheck Off,SafeOnly,On
* debuginfo None = "None",
			VS = "VS",
			Mago = "Mago",
* debugcode 
        DebugFull
        DebugLight
        Release
* dwarnings 
        "Error",
        "Info",
        "None",
* deprecatedfeatures 
        "Error",
        "Info",
        "Allow",

### Example ###

The contents of your premake5.lua file would be:

```lua
solution "MySolution"
    configurations { "release", "debug" }

    project "MyDProject"
        kind "ConsoleApp"
        language "D"
        files { "src/main.d", "src/extra.d" }
```
