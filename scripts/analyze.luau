local process = require("@lute/process")

local project = require("@root/project")
local run = require("@scripts/lib/run")

local globalDefsPath = "globalTypes.d.luau"

run("curl", {
	"-s",
	"-o",
	globalDefsPath,
	"-O",
	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua",
})

local defaultArgs = {
	"analyze",
	`--defs={globalDefsPath}`,
	"--settings=./.vscode/settings.json",
	`--ignore="**/_Index/**"`,
	`--ignore="**/LuauPackages/**"`,
}

local failureCount = 0

do
	local args = table.clone(defaultArgs)
	table.insert(args, "--platform=standard")
	table.insert(args, "--flag:LuauSolverV2=true")
	table.insert(args, project.SCRIPTS_PATH)

	local ok = pcall(function()
		run("luau-lsp", args)
	end)

	if not ok then
		failureCount += 1
	end
end

do
	run("rojo", {
		"sourcemap",
		"-o",
		"sourcemap.json",
	})

	local args = table.clone(defaultArgs)
	table.insert(args, `--sourcemap=sourcemap.json`)
	table.insert(args, project.SOURCE_PATH)

	local ok = pcall(function()
		run("luau-lsp", args)
	end)

	if not ok then
		failureCount += 1
	end
end

process.exit(failureCount)
