local test = require("@std/test")
local testTypes = require("@std/test/types")

local downloadPinned = require("@scripts/lib/downloadPinned")

type TestSuite = testTypes.TestSuite
type Asserts = testTypes.Asserts

test.suite("downloadPinned", function(suite: TestSuite)
	suite:case("parses openssl SHA2-256 output", function(asserts: Asserts)
		asserts.eq(
			"dffa9173bd1ac910906155d5272f83e7b9d3f9dadc17eba980d26c280c227fe3",
			downloadPinned.parseSha256(
				"SHA2-256(globalTypes.d.lua)= DFFA9173BD1AC910906155D5272F83E7B9D3F9DADC17EBA980D26C280C227FE3\n"
			)
		)
	end)

	suite:case("parses openssl SHA256 output", function(asserts: Asserts)
		asserts.eq(
			"923653f16692a8a8a435ef2a35774b46835b2382aaeb9c84a069bc5800739928",
			downloadPinned.parseSha256(
				"SHA256(rbxasset.zip)= 923653f16692a8a8a435ef2a35774b46835b2382aaeb9c84a069bc5800739928\n"
			)
		)
	end)

	suite:case("rejects a truncated digest", function(asserts: Asserts)
		local ok = pcall(function()
			downloadPinned.parseSha256("SHA256(file)= abc123\n")
		end)
		asserts.eq(false, ok)
	end)
end)
