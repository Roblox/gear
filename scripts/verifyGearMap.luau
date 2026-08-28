local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local GearMap = require("@root/src/GearMap") :: { [string]: string? }
local project = require("@root/project")

local mismatches = {}

for _, fileName in fs.readDir(project.RAW_GEAR_ASSETS_PATH) do
	local assetId = fileName:match("^(%d+)%.rbxm$")
	if assetId == nil then
		continue
	end

	local instances = roblox.deserializeModel(fs.readFile(`{project.RAW_GEAR_ASSETS_PATH}/{fileName}`))
	local root = instances[1]
	local mappedName = GearMap[assetId]
	if mappedName ~= root.Name then
		table.insert(mismatches, `{assetId}: GearMap={tostring(mappedName)}, RBXM={root.Name}`)
	end
end

table.sort(mismatches)
if #mismatches > 0 then
	error(`GearMap does not preserve raw root names:\n{table.concat(mismatches, "\n")}`)
end

print("GearMap matches every raw RBXM root name")
