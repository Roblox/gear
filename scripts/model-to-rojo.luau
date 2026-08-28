local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local project = require("@root/project")
local assertGearRoot = require("@scripts/lib/roblox/assertGearRoot")
local dumpModel = require("@scripts/lib/roblox/dumpModel")

-- All arguments to this script are paths to the Gear under `assets`. Use
-- scripts/download-gear.luau first if an asset is not there yet.
local modelPaths = process.args

local all = process.args[1] == "--all"

if all then
	local paths = {}
	for _, modelFile in fs.readDir(project.RAW_GEAR_ASSETS_PATH) do
		table.insert(paths, `{project.RAW_GEAR_ASSETS_PATH}/{modelFile}`)
	end
	modelPaths = paths
end

for _, modelFile in modelPaths do
	local assetId = modelFile:match("(%d+)%.rbxm")
	assert(assetId, `could not parse an asset ID from {modelFile}`)
	print("Dumping", modelFile)
	local model = roblox.deserializeModel(fs.readFile(modelFile))[1]
	assertGearRoot(model, assetId)
	model.Name = assetId
	dumpModel(model, assetId)
end
