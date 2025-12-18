--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getUploadedAssetForComparison = require(ReplicatedStorage.Src.getUploadedAssetForComparison)
local compareGear = require(ReplicatedStorage.Src.compareGear)
local ObjectStatus = require(ReplicatedStorage.Src.ObjectStatus)
local GearMap = require(ReplicatedStorage.Src.GearMap)

local allGearModifications = {}
local gearModificationCount = 0
for _, generatedGear in ReplicatedStorage.Src.gear:GetChildren() do
	local modifications, modificationsPresent = compareGear(getUploadedAssetForComparison(generatedGear), generatedGear)
	if modificationsPresent then
		allGearModifications[generatedGear.Name] = modifications
		gearModificationCount += 1
	end
end

local function getGearProjectNameFromId(gearId: string)
	return GearMap[gearId]
end

local statusesToMarkdownText = {
	[ObjectStatus.ADDED] = "Additions",
	[ObjectStatus.MODIFIED] = "Modifications",
	[ObjectStatus.REMOVED] = "Removals",
}
print(`# 🛠️ Gear Changes ({gearModificationCount})\n`)
for gearId, gearModifications in allGearModifications do
	print(`## [🔗 {getGearProjectNameFromId(gearId)}](https://roblox.com/catalog/{gearId}/)\n`)

	for category, categoryModifications in gearModifications do
		if #categoryModifications == 0 then
			continue
		end

		print(`### {statusesToMarkdownText[category]} ({#categoryModifications})\n`)

		for _, modification in categoryModifications do
			local path = modification.path

			if category == ObjectStatus.MODIFIED then
				print(
					`- 🟡 \`{path}\` **{modification.status}**: \`{modification.oldValue}\` --> \`{modification.newValue}\``
				)
			elseif category == ObjectStatus.ADDED then
				print(`- 🟢 \`{path}\` **{modification.status}**`)
			elseif category == ObjectStatus.REMOVED then
				print(`- 🔴 \`{path}\` **{modification.status}**`)
			end
		end

		print()
	end
end
if next(allGearModifications) == nil then
	print(`✅ No modifications detected!`)
end

print("### END OF COMPARISON")
