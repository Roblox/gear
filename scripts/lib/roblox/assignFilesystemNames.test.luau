local test = require("@std/test")

local assignFilesystemNames = require("@scripts/lib/roblox/assignFilesystemNames")

local function assign(names: { string })
	return assignFilesystemNames.assign(names, function(name)
		return name
	end)
end

test.suite("assignFilesystemNames", function(suite)
	suite:case("leaves unique names unchanged", function(asserts)
		local assignments = assign({ "Handle", "Mesh", "Sound" })

		asserts.eq("Handle", assignments[1].filesystemName)
		asserts.eq(nil, assignments[1].originalName)
		asserts.eq("Mesh", assignments[2].filesystemName)
		asserts.eq(nil, assignments[2].originalName)
	end)

	suite:case("encodes every member of a duplicate group", function(asserts)
		local assignments = assign({ "Weld", "Weld", "Weld" })

		asserts.eq("Weld__1", assignments[1].filesystemName)
		asserts.eq("Weld", assignments[1].originalName)
		asserts.eq("Weld__2", assignments[2].filesystemName)
		asserts.eq("Weld", assignments[2].originalName)
		asserts.eq("Weld__3", assignments[3].filesystemName)
		asserts.eq("Weld", assignments[3].originalName)
	end)

	suite:case("treats case-only names as filesystem collisions", function(asserts)
		local assignments = assign({ "Part", "part" })

		asserts.eq("Part__1", assignments[1].filesystemName)
		asserts.eq("Part", assignments[1].originalName)
		asserts.eq("part__2", assignments[2].filesystemName)
		asserts.eq("part", assignments[2].originalName)
	end)

	suite:case("does not collide with a genuine suffixed sibling", function(asserts)
		local assignments = assign({ "Weld", "Weld", "Weld__1" })

		asserts.eq("Weld__2", assignments[1].filesystemName)
		asserts.eq("Weld__3", assignments[2].filesystemName)
		asserts.eq("Weld__1", assignments[3].filesystemName)
		asserts.eq(nil, assignments[3].originalName)
	end)
end)
