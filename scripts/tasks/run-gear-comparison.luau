--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getUploadedAssetForComparison = require(ReplicatedStorage.Src.getUploadedAssetForComparison)
local compareGear = require(ReplicatedStorage.Src.compareGear)
local ObjectStatus = require(ReplicatedStorage.Src.ObjectStatus)
local GearMap = require(ReplicatedStorage.Src.GearMap)
local preloadSounds = require(ReplicatedStorage.Src.preloadSounds)

preloadSounds({ ReplicatedStorage.Src.gear, ReplicatedStorage.Assets })

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

local markdown: { string } = {}

table.insert(markdown, `# 🛠️ Gear Changes ({gearModificationCount})\n`)
for gearId, gearModifications in allGearModifications do
	table.insert(markdown, `## [🔗 {getGearProjectNameFromId(gearId)}](https://roblox.com/catalog/{gearId}/)\n`)

	for category, categoryModifications in gearModifications do
		if #categoryModifications == 0 then
			continue
		end

		table.insert(markdown, `### {statusesToMarkdownText[category]} ({#categoryModifications})\n`)

		for _, modification in categoryModifications do
			local path = modification.path

			if category == ObjectStatus.MODIFIED then
				table.insert(
					markdown,
					`- 🟡 \`{path}\` **{modification.status}**: \`{modification.oldValue}\` --> \`{modification.newValue}\``
				)
			elseif category == ObjectStatus.ADDED then
				table.insert(markdown, `- 🟢 \`{path}\` **{modification.status}**`)
			elseif category == ObjectStatus.REMOVED then
				table.insert(markdown, `- 🔴 \`{path}\` **{modification.status}**`)
			end
		end

		table.insert(markdown, "")
	end
end
if next(allGearModifications) == nil then
	table.insert(markdown, `✅ No modifications detected!`)
end

return table.concat(markdown, "\n")
