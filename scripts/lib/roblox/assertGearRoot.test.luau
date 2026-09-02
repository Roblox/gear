local test = require("@std/test")
local testTypes = require("@std/test/types")

local assertGearRoot = require("@scripts/lib/roblox/assertGearRoot")

type TestSuite = testTypes.TestSuite
type Asserts = testTypes.Asserts

local function model(className: string, name: string)
	return { ClassName = className, Name = name }
end

test.suite("assertGearRoot", function(suite: TestSuite)
	suite:case("accepts a Tool root", function(asserts: Asserts)
		local tool = model("Tool", "PumpkinSword")
		asserts.eq(tool, assertGearRoot(tool, "36568418"))
	end)

	suite:case("accepts a legacy HopperBin root", function(asserts: Asserts)
		local hopperBin = model("HopperBin", "Part Dragger")
		asserts.eq(hopperBin, assertGearRoot(hopperBin, "16200204"))
	end)

	-- Called through a closure rather than passed to pcall directly: pcall
	-- cannot instantiate the generic parameter across the call boundary.
	suite:case("rejects a Hat root", function(asserts: Asserts)
		local ok, err = pcall(function()
			return assertGearRoot(model("Hat", "DaVinci Helicopter"), "23307906")
		end)
		asserts.eq(false, ok)
		asserts.eq(true, string.find(tostring(err), "non-Gear root Hat DaVinci Helicopter", 1, true) ~= nil)
	end)

	suite:case("rejects an Accessory root", function(asserts: Asserts)
		local ok = pcall(function()
			assertGearRoot(model("Accessory", "DragonShades"), "2846247073")
		end)
		asserts.eq(false, ok)
	end)
end)
