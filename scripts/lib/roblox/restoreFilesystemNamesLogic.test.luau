local test = require("@std/test")

local restoreFilesystemNames = require("@scripts/lib/roblox/restoreFilesystemNamesLogic")

type Node = {
	id: string,
	name: string,
	originalName: string?,
	children: { Node },
}

local function node(id: string, name: string, originalName: string?, children: { Node }?): Node
	return {
		id = id,
		name = name,
		originalName = originalName,
		children = children or {},
	}
end

local adapter: restoreFilesystemNames.Adapter<Node> = {
	getChildren = function(instance)
		return instance.children
	end,
	getName = function(instance)
		return instance.name
	end,
	setName = function(instance, name)
		instance.name = name
	end,
	getOriginalName = function(instance)
		return instance.originalName
	end,
	clearOriginalName = function(instance)
		instance.originalName = nil
	end,
	reparentInOrder = function(parent, ordered)
		local moving = {}
		for _, instance in ordered do
			moving[instance] = true
		end

		local children = {}
		for _, child in parent.children do
			if not moving[child] then
				table.insert(children, child)
			end
		end
		for _, child in ordered do
			table.insert(children, child)
		end
		parent.children = children
	end,
}

test.suite("restoreFilesystemNamesLogic", function(suite)
	suite:case("does nothing to ordinary names", function(asserts)
		local root = node("root", "Root", nil, {
			node("handle", "Handle"),
		})

		asserts.eq(0, restoreFilesystemNames(root, adapter))
		asserts.eq("Handle", root.children[1].name)
	end)

	suite:case("restores names and clears temporary metadata", function(asserts)
		local weld = node("1", "Weld__1", "Weld")
		local root = node("root", "Root", nil, { weld })

		asserts.eq(1, restoreFilesystemNames(root, adapter))
		asserts.eq("Weld", weld.name)
		asserts.eq(nil, weld.originalName)
	end)

	suite:case("repairs lexical ordering numerically", function(asserts)
		local weld1 = node("1", "Weld__1", "Weld")
		local weld10 = node("10", "Weld__10", "Weld")
		local weld2 = node("2", "Weld__2", "Weld")
		local sound = node("sound", "Sound")
		local root = node("root", "Root", nil, {
			weld1,
			weld10,
			weld2,
			sound,
		})

		asserts.eq(3, restoreFilesystemNames(root, adapter))
		asserts.eq("sound", root.children[1].id)
		asserts.eq("1", root.children[2].id)
		asserts.eq("2", root.children[3].id)
		asserts.eq("10", root.children[4].id)
		asserts.eq("Weld", root.children[2].name)
		asserts.eq("Weld", root.children[3].name)
		asserts.eq("Weld", root.children[4].name)
	end)

	suite:case("restores nested duplicate groups", function(asserts)
		local child2 = node("child2", "Part__2", "Part")
		local child1 = node("child1", "Part__1", "Part")
		local folder2 = node("folder2", "Folder__2", "Folder", { child2, child1 })
		local folder1 = node("folder1", "Folder__1", "Folder")
		local root = node("root", "Root", nil, { folder2, folder1 })

		asserts.eq(4, restoreFilesystemNames(root, adapter))
		asserts.eq("folder1", root.children[1].id)
		asserts.eq("folder2", root.children[2].id)
		asserts.eq("child1", folder2.children[1].id)
		asserts.eq("child2", folder2.children[2].id)
	end)

	suite:case("does not combine case-distinct original names", function(asserts)
		local upper = node("upper", "Part__1", "Part")
		local lower = node("lower", "part__2", "part")
		local root = node("root", "Root", nil, { upper, lower })

		asserts.eq(2, restoreFilesystemNames(root, adapter))
		asserts.eq("Part", root.children[1].name)
		asserts.eq("part", root.children[2].name)
	end)

	suite:case("rejects a malformed prefix", function(asserts)
		local root = node("root", "Root", nil, {
			node("weld", "Other__1", "Weld"),
		})
		local ok, message = pcall(function()
			restoreFilesystemNames(root, adapter)
		end)

		asserts.eq(false, ok)
		asserts.eq(true, string.find(message, "does not start with expected prefix Weld__", 1, true) ~= nil)
	end)

	suite:case("rejects a non-numeric suffix", function(asserts)
		local root = node("root", "Root", nil, {
			node("weld", "Weld__first", "Weld"),
		})
		local ok, message = pcall(function()
			restoreFilesystemNames(root, adapter)
		end)

		asserts.eq(false, ok)
		asserts.eq(true, string.find(message, "does not end with a numeric duplicate index", 1, true) ~= nil)
	end)
end)
