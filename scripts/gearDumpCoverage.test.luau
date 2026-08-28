local fs = require("@lute/fs")
local test = require("@std/test")
local testTypes = require("@std/test/types")

local project = require("@root/project")

type TestSuite = testTypes.TestSuite
type Asserts = testTypes.Asserts

test.suite("gear dump coverage", function(suite: TestSuite)
	suite:case("has a dump for every raw gear asset", function(asserts: Asserts)
		local missing = {}

		for _, assetFile in fs.listdir(project.RAW_GEAR_ASSETS_PATH) do
			local assetId = assetFile.name:match("^(%d+)%.rbxm$")
			if assetId ~= nil then
				local dumpPath = `{project.GEAR_PATH}/{assetId}`
				if not fs.exists(`{dumpPath}/default.project.json`) or not fs.exists(`{dumpPath}/src`) then
					table.insert(missing, assetId)
				end
			end
		end

		table.sort(missing)
		asserts.eq({}, missing)
	end)
end)
