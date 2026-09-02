local process = require("@lute/process")

local downloadPinned = require("@scripts/lib/downloadPinned")
local project = require("@root/project")
local run = require("@scripts/lib/run")

local globalDefsPath = "globalTypes.d.luau"

downloadPinned.downloadPinned(
	`https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/{project.LUAU_LSP_COMMIT}/scripts/globalTypes.d.lua`,
	globalDefsPath,
	project.LUAU_LSP_GLOBAL_TYPES_SHA256
)

local defaultArgs = {
	"analyze",
	`--defs={globalDefsPath}`,
	"--settings=./.vscode/settings.json",
	`--ignore="**/_Index/**"`,
	`--ignore="**/LuauPackages/**"`,
	-- Dumped catalog scripts are not ours to type-check yet.
	`--ignore="src/gear/**"`,
}

local failureCount = 0

do
	local args = table.clone(defaultArgs)
	table.insert(args, "--platform=standard")
	table.insert(args, "--flag:LuauSolverV2=true")
	table.insert(args, project.SCRIPTS_PATH)
	table.insert(args, project.SITE_PATH)

	local ok = pcall(function()
		run("luau-lsp", args)
	end)

	if not ok then
		failureCount += 1
	end
end

do
	-- `src` requires resolve through the tests place, which is the only project
	-- that mounts src and Packages under ReplicatedStorage.
	run("rojo", {
		"sourcemap",
		project.TESTS_PROJECT_PATH,
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
