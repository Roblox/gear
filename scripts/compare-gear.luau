local process = require("@lute/process")
local fs = require("@lute/fs")

local cli = require("@luaupkg/batteries/cli")
local project = require("@root/project")
local dotenv = require("@scripts/lib/dotenv")

dotenv()

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key used for running Luau Execution. Can also be "
		.. "supplied by the ROBLOX_API_KEY environment variable",
	aliases = { "k" },
})

args:add("output", "option", {
	help = "File to output changes in Markdown format",
	aliases = { "o" },
})

args:parse({ ... })

local apiKey = process.env.ROBLOX_API_KEY or args:get("apiKey")
if not apiKey then
	error(
		"A valid Open Cloud API key must be supplied with either the --apiKey flag or the ROBLOX_API_KEY environment variable"
	)
end

local outputFile = args:get("output")
if outputFile then
	print("Building & running comparison...")
end

process.run({ "lune", "run", "scripts/build-rojo-project.luau", "tests.project.json", "tests.rbxl" }, {
	stdio = "inherit",
})

local result = process.run({
	"python3",
	"scripts/lib/python/upload_and_run_task.py",
	"tests.rbxl",
	"scripts/tasks/run-gear-comparison.luau",
}, {
	stdio = if outputFile == nil then "inherit" else nil,
	env = {
		ROBLOX_UNIVERSE_ID = project.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
		ROBLOX_PLACE_ID = project.ROBLOX_UNIT_TESTING_PLACE_ID,
		ROBLOX_API_KEY = tostring(apiKey),
	},
})

if result.ok and outputFile ~= nil then
	local markdown = result.stdout:gsub("^(.*)Executing Luau task\n", ""):gsub("### END OF COMPARISON(.+)$", "")
	local fd = fs.open(outputFile, "w+")
	fs.write(fd, markdown)
end
