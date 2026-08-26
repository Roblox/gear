local cli = require("@luaupkg/batteries/cli")
local fs = require("@lute/fs")
local process = require("@lute/process")

local executeLuauTaskAsync = require("@scripts/lib/luau-execution/executeLuauTaskAsync")
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

process.run({ "lune", "run", "scripts/build-rojo-project.luau", "tests.project.json", `tests.rbxl` }, {
	stdio = "inherit",
})

local runTestsTaskHandle = fs.open("scripts/tasks/run-tests.luau")
local runTestsTask = fs.read(runTestsTaskHandle)
fs.close(runTestsTaskHandle)

local results = executeLuauTaskAsync(
	"tests.rbxl",
	runTestsTask,
	project.ROBLOX_UNIT_TESTING_UNIVERSE_ID,
	project.ROBLOX_UNIT_TESTING_PLACE_ID,
	apiKey
)

local success = results[1]

fs.remove("tests.rbxl")

process.exit(if success == true then 0 else 1)
