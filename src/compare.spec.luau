local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local JestGlobals = require(ReplicatedStorage.Packages.JestGlobals)
local GearMap = require(ReplicatedStorage.Src.GearMap)
local compareGear = require(ReplicatedStorage.Src.compareGear)
local getUploadedAssetForComparison = require(ReplicatedStorage.Src.getUploadedAssetForComparison)

local describe = JestGlobals.describe
local test = JestGlobals.test
local expect = JestGlobals.expect

-- NOTE: We really only need to compare when ingesting _new_ gear
-- assets. This is all to make sure that the newly exported files map
-- 1:1 with the raw asset rbxm

local function preloadSounds(...)
	local sounds = {}
	for _, root in { ... } do
		if root == nil then
			continue
		end
		if root:IsA("Sound") then
			table.insert(sounds, root)
		end
		for _, descendant in root:GetDescendants() do
			if descendant:IsA("Sound") then
				table.insert(sounds, descendant)
			end
		end
	end

	if #sounds > 0 then
		ContentProvider:PreloadAsync(sounds)
	end
end

local gearToTest = {}
for _, gear in ReplicatedStorage.Src.gear:GetChildren() do
	table.insert(gearToTest, {
		gear = gear,
		gearName = GearMap[gear.Name],
	})
end
describe.each(gearToTest)("$gearName", function(args)
	local generatedGear = args.gear
	local uploadedGear = getUploadedAssetForComparison(generatedGear)

	test("uploaded counterpart should exist in `assets`", function()
		expect(uploadedGear).toBeDefined()
	end)

	test("uploaded asset should match generated asset", function()
		preloadSounds(uploadedGear, generatedGear)
		local modifications, modificationsPresent = compareGear(uploadedGear, generatedGear)
		local checkValue = if modificationsPresent then modifications else nil
		expect(checkValue).never.toBeDefined()
	end)
end)
