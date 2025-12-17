local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.Packages.JestGlobals)

local describe = JestGlobals.describe
local test = JestGlobals.test
local expect = JestGlobals.expect

local function getRawAssetForComparison(sourceGear: Instance): Instance?
	for _, rawGear in ReplicatedStorage.Assets:GetChildren() do
		if rawGear.Name == sourceGear.Name then
			return rawGear
		end
	end
	return nil
end

-- NOTE: We really only need to compare when ingesting _new_ gear
-- assets. This is all to make sure that the newly exported files map
-- 1:1 with the raw asset rbxm

describe.each(ReplicatedStorage.Src.gear:GetChildren())("%s", function(gear)
	local rawGear = getRawAssetForComparison(gear)

	test("counterpart exists in `assets`", function()
		expect(rawGear).toBeDefined()
	end)

	test("compare", function()
		-- TODO: Compare `raw` with `gear` to make sure they have all the same
		-- descendants and properties
		expect(true).toBe(false)
	end)
end)
