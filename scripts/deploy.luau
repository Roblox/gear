local fs = require("@lute/fs")
local process = require("@lute/process")
local cli = require("@luaupkg/batteries/cli")
local pp = require("@luaupkg/batteries/pp")

local project = require("@root/project")
local dotenv = require("@scripts/lib/dotenv")

local args = cli.parser()

args:add("projectPath", "option", {
	help = "Path to the Gear asset to upload",
})

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:add("all", "flag", {
	help = "Run this command for every Gear asset",
})

args:parse({ ... })

dotenv()

local apiKey = args:get("apiKey") or process.env.ROBLOX_API_KEY
if not apiKey then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

local projectPaths = {}

if args:has("all") then
	for _, dir in fs.listdir(project.GEAR_PATH) do
		local path = `{project.GEAR_PATH}/{dir.name}`

		if not fs.exists(`{path}/rbxasset.toml`) then
			print(`no rbxasset.toml found in {dir.name}. skipping...`)
			continue
		end

		table.insert(projectPaths, path)
	end
else
	local projectPath = args:get("projectPath")

	assert(projectPath ~= nil, "--projectPath must be supplied when --all is not passed")
	assert(fs.exists(`{projectPath}/rbxasset.toml`), `no rbxasset.toml found in {projectPath}`)

	table.insert(projectPaths, projectPath)
end

print(`using project paths: {pp(projectPaths)}`)

for _, projectPath in projectPaths do
	process.run({ "rojo", "build", "-o", "build.rbxm" }, {
		cwd = projectPath,
		stdio = "inherit",
	})

	local cwd = process.cwd()

	process.run({
		"lune093",
		"run",
		`{cwd}/scripts/lib/roblox/deploy.luau`,
		".",
		apiKey,
	}, {
		stdio = "inherit",
		cwd = projectPath,
	})
end
