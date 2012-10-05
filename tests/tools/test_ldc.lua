--
-- tests/test_ldc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

	T.ldc = { }
	local suite = T.ldc

	local cfg
	function suite.setup()
		cfg = { }
		cfg.basedir    = "."
		cfg.location   = "."
		cfg.language   = "D"
		cfg.project    = { name = "MyProject" }
		cfg.flags      = { }
		cfg.objectsdir = "obj"
		cfg.platform   = "Native"
		cfg.links      = { }
		cfg.libdirs    = { }
		cfg.linktarget = { fullpath="libMyProject.a" }
        cfg.buildoptions = { "-gc" }
        cfg.linkoptions  = { "-L-Wl" }
	end


--
-- FLAGS tests
--

	function suite.flags_x32()
		cfg.system = "windows"
		cfg.platform = "x32"
		local r = premake.ldc.getflags(cfg)
		test.isequal("-m32 -release", table.concat(r, " "))
	end

	function suite.flags_x32_SharedLib()
		cfg.system = "linux"
		cfg.platform = "x32"
        cfg.kind = "SharedLib"
		local r = premake.ldc.getflags(cfg)
		test.isequal("-m32 -relocation-model=pic -release", table.concat(r, " "))
	end

	function suite.flags_x64()
		cfg.system = "linux"
		cfg.platform = "x64"
		local r = premake.ldc.getflags(cfg)
		test.isequal("-m64 -release", table.concat(r, " "))
	end

	function suite.flags_Optimize()
		cfg.system = "linux"
		cfg.flags = { "Optimize" }
		local r = premake.ldc.getflags(cfg)
		test.isequal("-O2  -release", table.concat(r, " "))
	end
--
-- DEFINES test
--

	function suite.defines_AsVersion()
		cfg.defines = { "abc" }
		local r = premake.ldc.getdefines(cfg.defines)
		test.isequal("-d-version=abc", table.concat(r, " "))
	end

--
-- LDFLAGS tests
--

	function suite.ldflags_SharedLib_Linux()
		cfg.kind = "SharedLib"
		cfg.system = "linux"
		local r = premake.ldc.getldflags(cfg)
		test.isequal('', table.concat(r,"|"))
	end

-- 
-- DFLAGS test
--

	function suite.flags_IsStaticLib()
		cfg.kind = "StaticLib"
		cfg.system = "linux"
		local r = premake.ldc.getflags(cfg)
		test.isequal(" -lib -release", table.concat(r," "))
	end



