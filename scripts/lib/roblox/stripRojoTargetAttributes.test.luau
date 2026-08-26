local test = require("@std/test")

local stripRojoTargetAttributes = require("@scripts/lib/roblox/stripRojoTargetAttributes")

type Node = {
	attributes: { [string]: any },
	children: { Node },
	GetAttributes: (Node) -> { [string]: any },
	SetAttribute: (Node, string, any) -> (),
	GetChildren: (Node) -> { Node },
}

local function node(attributes: { [string]: any }?, children: { Node }?): Node
	local instance = {
		attributes = attributes or {},
		children = children or {},
	}

	function instance:GetAttributes()
		return table.clone(self.attributes)
	end

	function instance:SetAttribute(name, value)
		self.attributes[name] = value
	end

	function instance:GetChildren()
		return self.children
	end

	return instance
end

test.suite("stripRojoTargetAttributes", function(suite)
	suite:case("removes target attributes throughout the tree", function(asserts)
		local weld = node({
			Rojo_Target_Part0 = "handle",
			Rojo_Target_Part1 = "handle",
		})
		local objectValue = node({
			Rojo_Target_Value = "target",
		})
		local root = node({}, { weld, node({}, { objectValue }) })

		asserts.eq(3, stripRojoTargetAttributes(root))
		asserts.eq({}, weld.attributes)
		asserts.eq({}, objectValue.attributes)
	end)

	suite:case("preserves unrelated and original-name attributes", function(asserts)
		local root = node({
			Rojo_Id = "handle",
			__MarketplaceGear_OriginalName = "Weld",
			UserAttribute = 42,
			NotRojo_Target_Value = "keep",
			Rojo_Target_Part0 = "remove",
		})

		asserts.eq(1, stripRojoTargetAttributes(root))
		asserts.eq("handle", root.attributes.Rojo_Id)
		asserts.eq("Weld", root.attributes.__MarketplaceGear_OriginalName)
		asserts.eq(42, root.attributes.UserAttribute)
		asserts.eq("keep", root.attributes.NotRojo_Target_Value)
		asserts.eq(nil, root.attributes.Rojo_Target_Part0)
	end)

	suite:case("returns zero for a clean tree", function(asserts)
		local root = node({ UserAttribute = true }, {
			node(),
		})

		asserts.eq(0, stripRojoTargetAttributes(root))
		asserts.eq(true, root.attributes.UserAttribute)
	end)
end)
