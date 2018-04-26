--
-- d/actions/vcxproj.lua
-- Generate a VisualD .visualdproj project.
-- Copyright (c) 2012-2015 Manu Evans and the Premake project
--

	local p = premake

	require ("vstudio")

	p.modules.d.vc2010 = {}

	local m = p.modules.d.vc2010

	local vc2010 = p.vstudio.vc2010

	local vstudio = p.vstudio
--	local workspace = p.workspace
--	local project = p.project
	local config = p.config
--	local tree = p.tree

--
-- Patch the dCompile step into the project items
--
	p.override(vc2010.elements, "itemDefinitionGroup", function(oldfn, cfg)
		local items = oldfn(cfg)
		if cfg.kind ~= p.UTILITY then
			table.insertafter(items, vc2010.clCompile, m.dCompile)
		end
		return items
	end)


--
-- Write the <DCompile> settings block.
--

	m.elements.dCompile = function(cfg)
		local calls = {
			m.dOptimization,
			m.dImportPaths,
			m.dStringImportPaths,
			m.dVersionConstants,
			m.dDebugConstants,
			m.dCompilationModel,
			m.dRuntime,
			m.dCodeGeneration,
			m.dMessages,
			m.dDocumentation,
		}

		return calls
	end

	function m.dCompile(cfg)
		p.push('<DCompile>')
		p.callArray(m.elements.dCompile, cfg)
		p.pop('</DCompile>')
	end



---
-- DCompile group
---
	vc2010.categories.DCompile = {
		name       = "DCompile",
		extensions = { ".d" },
		priority   = 3,

		emitFiles = function(prj, group)
			local fileCfgFunc = function(fcfg, condition)
				if fcfg then
					return {
						m.excludedFromBuild,
						m.dOptimization,
						m.dImportPaths,
						m.dStringImportPaths,
						m.dVersionConstants,
						m.dDebugConstants,
						m.dCompilationModel,
						m.dRuntime,
						m.dCodeGeneration,
						m.dMessages,
						m.dDocumentation,
					}
				else
					return {
						m.excludedFromBuild
					}
				end
			end

			m.emitFiles(prj, group, "DCompile", {m.generatedFile}, fileCfgFunc)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "DCompile")
		end
	}


	--------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------
	-- D Functions

	function m.dOptimization(cfg, condition)
		local map = { Off="false", On="true", Debug="true", Full="true", Size="true", Speed="true" }
		if cfg.optimize then
			m.element('Optimizer', condition, map[cfg.optimize] or "false")
		end
	end


	function m.dImportPaths(cfg, condition)
		if cfg.importpaths and #cfg.importpaths > 0 then
			local importpaths = table.concat(cfg.importpaths, ";") .. ";%%(ImportPaths)"
			m.element("ImportPaths", condition, importpaths)
		end
	end


	function m.dStringImportPaths(cfg, condition)
		if cfg.stringimportpaths and #cfg.stringimportpaths > 0 then
			local stringimportpaths = table.concat(cfg.stringimportpaths, ";") .. ";%%(StringImportPaths)"
			m.element("StringImportPaths", condition, stringimportpaths)
		end
	end


	function m.dVersionConstants(cfg, condition)
		if cfg.versionconstants and #cfg.versionconstants > 0 then
			local versionconstants = table.concat(cfg.versionconstants, ";")
			m.element("VersionIdentifiers", condition, versionconstants)
		end
	end


	function m.dDebugConstants(cfg, condition)
		if cfg.debugconstants and #cfg.debugconstants > 0 then
			local debugconstants = table.concat(cfg.debugconstants, ";")
			m.element("DebugIdentifiers", condition, debugconstants)
		end
	end


	function m.dCompilationModel(cfg, condition)
		if cfg.compilationmodel then
			if cfg.compilationmodel == "Project" then
				m.element("CompilationModel", condition, "Project")
			elseif cfg.compilationmodel == "Package" then
				m.element("CompilationModel", condition, "Package")
			elseif cfg.compilationmodel == "File" then
				m.element("CompilationModel", condition, "File")
			end
		end
	end


	function m.dRuntime(cfg, condition)
		local releaseruntime = true
		local staticruntime = true
		if cfg.staticruntime then
			if cfg.staticruntime == "Off" then
				staticruntime = false
			end
		end
		if cfg.runtime then
			if cfg.runtime == "Debug" then
				releaseruntime = false
			end
		end
		if cfg.staticruntime or cfg.runtime then
			if staticruntime == true and releaseruntime == true then
				m.element("CRuntimeLibrary", condition, "MultiThreaded")
			elseif staticruntime == true and releaseruntime == false then
				m.element("CRuntimeLibrary", condition, "MultiThreadedDebug")
			elseif staticruntime == false and releaseruntime == true then
				m.element("CRuntimeLibrary", condition, "MultiThreadedDll")
			elseif staticruntime == false and releaseruntime == false then
				m.element("CRuntimeLibrary", condition, "MultiThreadedDebugDll")
			end
		end
	end


	function m.dCodeGeneration(cfg, condition)
		if cfg.buildtarget then
			local ObjectFileName = ""
			if cfg.buildtarget.basename then
				if cfg.buildtarget.prefix then
					ObjectFileName = cfg.buildtarget.prefix
				end
				ObjectFileName = ObjectFileName .. cfg.buildtarget.basename .. ".obj"
			end
			if cfg.buildtarget.directory then
				local outdir = vstudio.path(cfg, cfg.buildtarget.directory)
				ObjectFileName = path.join(outdir, ObjectFileName)
			end
			m.element("ObjectFileName", condition, ObjectFileName)
		end

		if cfg.optimize then
			if config.isOptimizedBuild(cfg) then
				m.element("Optimizer", condition, "true")
			end
		end
		if cfg.flags.Profile then
			m.element("Profile", condition, "true")
		end
		if cfg.flags.CodeCoverage then
			m.element("Coverage", condition, "true")
		end
		if cfg.flags.UnitTest then
			m.element("Unittest", condition, "true")
		end
		if cfg.inlining then
			local types = {
				Default = "true",
				Disabled = "false",
				Explicit = "true",
				Auto = "true",
			}
			m.element("Inliner", condition, types[cfg.inlining])
		end
		if cfg.boundscheck then
			local types = {
				Off = "Off",
				SafeOnly = "SafeOnly",
				On = "On",
			}
			m.element("BoundsCheck", condition, types[cfg.boundscheck])
		end
		if cfg.debugcode then
			local types = {
				DebugFull = "Debug",
				DebugLight = "Default",
				Release = "Release",
			}
			m.element("DebugCode", condition, types[cfg.debugcode])
		end
		if cfg.debuginfo then
			local types = {
				None = "None",
				VS = "VS",
				Mago = "Mago",
			}
			m.element("DebugInfo", condition, types[cfg.debuginfo])
		end
		if cfg.flags.ProfileGC then
			m.element("ProfileGC", condition, "true")
		end
		if cfg.flags.StackFrame then
			m.element("StackFrame", condition, "true")
		end
		if cfg.flags.StackStomp then
			m.element("StackStomp", condition, "true")
		end
		if cfg.flags.AllTemplateInst then
			m.element("AllInst", condition, "true")
		end
		if cfg.flags.BetterC then
			m.element("BetterC", condition, "true")
		end
		if cfg.flags.Main then
			m.element("Main", condition, "true")
		end
		if cfg.flags.PerformSyntaxCheckOnly then
			m.element("PerformSyntaxCheckOnly", condition, "true")
		end
	end


	function m.dMessages(cfg, condition)
		if cfg.dwarnings then
			local types = {
				Error = "Error",
				Info = "Info",
				None = "None",
			}
			m.element("Warnings", condition, types[cfg.dwarnings])
		end
		if cfg.deprecatedfeatures then
			local types = {
				Error = "Error",
				Info = "Info",
				Allow = "Allow",
			}
			m.element("Deprecations", condition, types[cfg.deprecatedfeatures])
		end
		if cfg.flags.ShowCommandLine then
			m.element("ShowCommandLine", condition, "true")
		end
		if cfg.flags.Verbose then
			m.element("Verbose", condition, "true")
		end
		if cfg.flags.ShowTLS then
			m.element("ShowTLS", condition, "true")
		end
		if cfg.flags.ShowGC then
			m.element("ShowGC", condition, "true")
		end
		if cfg.flags.IgnorePragma then
			m.element("IgnorePragma", condition, "true")
		end
		if cfg.flags.ShowDependencies then
			m.element("ShowDependencies", condition, "true")
		end
	end


	function m.dDocumentation(cfg, condition)
		if cfg.docdir then
			m.element("DocDir", condition, cfg.docdir)
		end
		if cfg.docname then
			m.element("DocFile", condition, cfg.docname)
		end
		if cfg.dependenciesfile then
			m.element("DepFile", condition, cfg.dependenciesfile)
		end
		if cfg.headerdir then
			m.element("HeaderDir", condition, cfg.headerdir)
		end
		if cfg.headername then
			m.element("HeaderFile", condition, cfg.headername)
		end
		if cfg.jsonfile then
			m.element("JSONFile", condition, cfg.jsonfile)
		end
	end
