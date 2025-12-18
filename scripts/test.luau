local cli = require("@luaupkg/batteries/cli")
local fs = require("@lute/fs")
local process = require("@lute/process")

local project = require("@root/project")
local dotenv = require("@scripts/lib/dotenv")

dotenv()

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:parse({ ... })

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
if not apiKey then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

process.run({
	"rojo",
	"build",
	"tests.project.json",
	"-o",
	"tests.rbxl",
}, {
	stdio = "inherit",
})

local result = process.run({
	"python3",
	"scripts/lib/python/upload_and_run_task.py",
	"tests.rbxl",
	"scripts/tasks/run-tests.luau",
}, {
	stdio = "inherit",
	env = {
		ROBLOX_UNIVERSE_ID = project.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
		ROBLOX_PLACE_ID = project.ROBLOX_UNIT_TESTING_PLACE_ID,
		ROBLOX_API_KEY = tostring(apiKey),
	},
})

fs.remove("tests.rbxl")

process.exit(result.exitcode)
