local process = require("@lute/process")
local fs = require("@lute/fs")

local cli = require("@luaupkg/batteries/cli")
local dotenv = require("@scripts/lib/dotenv")
local executeLuauTaskAsync = require("@scripts/lib/luau-execution/executeLuauTaskAsync")
local testingPlace = require("@scripts/lib/testingPlace")

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

local runGearComparisonsTaskHandle = fs.open("scripts/tasks/run-gear-comparison.luau")
local runGearComparisonsTask = fs.read(runGearComparisonsTaskHandle)
fs.close(runGearComparisonsTaskHandle)

local results = executeLuauTaskAsync(
	"tests.rbxl",
	runGearComparisonsTask,
	testingPlace.universeId(),
	testingPlace.placeId(),
	apiKey
)

local markdown = results[1]
if markdown == nil then
	error("the comparison task returned no output")
end

if outputFile ~= nil then
	local fd = fs.open(outputFile, "w+")
	fs.write(fd, markdown)
	fs.close(fd)
end
