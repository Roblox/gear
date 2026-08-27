-- Tests for `serializeProperty.luau`. Run via `lute test`.
--
-- Roblox datatypes are mocked as plain Luau tables matching the shape
-- the serializer reads (e.g. `{X, Y, Z}` for Vector3). The serializer
-- never introspects userdata identity, so this is faithful coverage
-- without dragging in `@lune/roblox`.

local test = require("@std/test")
local testTypes = require("@std/test/types")

-- Annotating the callbacks keeps each `asserts.eq` call generic. Without it the
-- inferred parameter gets a single `eq` signature shared by every comparison.
type Asserts = testTypes.Asserts
type TestSuite = testTypes.TestSuite

local serializePropertyModule = require("@scripts/lib/roblox/serializeProperty")
local serializeProperty = serializePropertyModule.serializeProperty
local SERIALIZERS = serializePropertyModule.SERIALIZERS

local function fakeCFrame(components: { number })
	return {
		GetComponents = function(_self)
			return table.unpack(components)
		end,
	}
end

test.suite("serializeProperty", function(suite: TestSuite)
	suite:case("Bool true", function(asserts: Asserts)
		local v, status = serializeProperty("Bool", true)
		asserts.eq("ok", status)
		asserts.eq(true, v)
	end)

	suite:case("Bool false", function(asserts: Asserts)
		local v, status = serializeProperty("Bool", false)
		asserts.eq("ok", status)
		asserts.eq(false, v)
	end)

	suite:case("String", function(asserts: Asserts)
		local v, status = serializeProperty("String", "hello")
		asserts.eq("ok", status)
		asserts.eq("hello", v)
	end)

	suite:case("Int32", function(asserts: Asserts)
		local v, status = serializeProperty("Int32", 42)
		asserts.eq("ok", status)
		asserts.eq(42, v)
	end)

	suite:case("Int64", function(asserts: Asserts)
		local v, status = serializeProperty("Int64", 9999999999)
		asserts.eq("ok", status)
		asserts.eq(9999999999, v)
	end)

	suite:case("Float32", function(asserts: Asserts)
		local v, status = serializeProperty("Float32", 1.5)
		asserts.eq("ok", status)
		asserts.eq(1.5, v)
	end)

	suite:case("Float64", function(asserts: Asserts)
		local v, status = serializeProperty("Float64", 2.25)
		asserts.eq("ok", status)
		asserts.eq(2.25, v)
	end)

	suite:case("Vector2", function(asserts: Asserts)
		local v, status = serializeProperty("Vector2", { X = 3, Y = 4 })
		asserts.eq("ok", status)
		asserts.eq({ 3, 4 }, v)
	end)

	suite:case("Vector3", function(asserts: Asserts)
		local v, status = serializeProperty("Vector3", { X = 1, Y = 2, Z = 3 })
		asserts.eq("ok", status)
		asserts.eq({ 1, 2, 3 }, v)
	end)

	suite:case("UDim2", function(asserts: Asserts)
		local v, status = serializeProperty("UDim2", {
			X = { Scale = 0.5, Offset = 12 },
			Y = { Scale = 1, Offset = -24 },
		})
		asserts.eq("ok", status)
		asserts.eq({
			UDim2 = {
				{ 0.5, 12 },
				{ 1, -24 },
			},
		}, v)
	end)

	suite:case("NumberRange", function(asserts: Asserts)
		local v, status = serializeProperty("NumberRange", { Min = -36, Max = 94 })
		asserts.eq("ok", status)
		asserts.eq({ NumberRange = { -36, 94 } }, v)
	end)

	suite:case("NumberSequence", function(asserts: Asserts)
		local v, status = serializeProperty("NumberSequence", {
			Keypoints = {
				{ Time = 0, Value = 5, Envelope = 2 },
				{ Time = 1, Value = 22, Envelope = 0 },
			},
		})
		asserts.eq("ok", status)
		asserts.eq({
			NumberSequence = {
				keypoints = {
					{ time = 0, value = 5, envelope = 2 },
					{ time = 1, value = 22, envelope = 0 },
				},
			},
		}, v)
	end)

	suite:case("Color3", function(asserts: Asserts)
		local v, status = serializeProperty("Color3", { R = 0.25, G = 0.5, B = 0.75 })
		asserts.eq("ok", status)
		asserts.eq({ 0.25, 0.5, 0.75 }, v)
	end)

	suite:case("BrickColor", function(asserts: Asserts)
		local v, status = serializeProperty("BrickColor", { Number = 194 })
		asserts.eq("ok", status)
		asserts.eq({ BrickColor = 194 }, v)
	end)

	suite:case("ColorSequence", function(asserts: Asserts)
		local v, status = serializeProperty("ColorSequence", {
			Keypoints = {
				{ Time = 0, Value = { R = 1, G = 1, B = 0.5 } },
				{ Time = 1, Value = { R = 0, G = 0.25, B = 0.75 } },
			},
		})
		asserts.eq("ok", status)
		asserts.eq({
			ColorSequence = {
				keypoints = {
					{ time = 0, color = { 1, 1, 0.5 } },
					{ time = 1, color = { 0, 0.25, 0.75 } },
				},
			},
		}, v)
	end)

	suite:case("CFrame flat 12-element list", function(asserts: Asserts)
		local v, status = serializeProperty("CFrame", fakeCFrame({ 1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1 }))
		asserts.eq("ok", status)
		asserts.eq({ 1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, 1 }, v)
	end)

	suite:case("OptionalCFrame uses Rojo's tagged explicit form", function(asserts: Asserts)
		local v, status = serializeProperty("OptionalCFrame", fakeCFrame({ 0, -1, 0, 1, 0, 0, 0, 0, -1, 0, 1, 0 }))
		asserts.eq("ok", status)
		asserts.eq({
			OptionalCFrame = {
				position = { 0, -1, 0 },
				orientation = { { 1, 0, 0 }, { 0, 0, -1 }, { 0, 1, 0 } },
			},
		}, v)
	end)

	suite:case("Content userdata uses .Uri", function(asserts: Asserts)
		local v, status = serializeProperty("Content", { Uri = "rbxassetid://12345" })
		asserts.eq("ok", status)
		asserts.eq("rbxassetid://12345", v)
	end)

	suite:case("ContentId aliases Content", function(asserts: Asserts)
		local v, status = serializeProperty("ContentId", { Uri = "rbxassetid://67890" })
		asserts.eq("ok", status)
		asserts.eq("rbxassetid://67890", v)
	end)

	suite:case("ContentId tolerates raw string default", function(asserts: Asserts)
		local v, status = serializeProperty("ContentId", "")
		asserts.eq("ok", status)
		asserts.eq("", v)
	end)

	suite:case("PhysicalProperties", function(asserts: Asserts)
		local v, status = serializeProperty("PhysicalProperties", {
			Density = 0.5,
			Friction = 1,
			Elasticity = 0,
			FrictionWeight = 50,
			ElasticityWeight = 25,
		})
		asserts.eq("ok", status)
		asserts.eq({
			PhysicalProperties = {
				density = 0.5,
				friction = 1,
				elasticity = 0,
				frictionWeight = 50,
				elasticityWeight = 25,
			},
		}, v)
	end)

	suite:case("BinaryString encodes bytes as base64", function(asserts: Asserts)
		local v, status = serializeProperty("BinaryString", "Hello, world!")
		asserts.eq("ok", status)
		asserts.eq({ BinaryString = "SGVsbG8sIHdvcmxkIQ==" }, v)
	end)

	suite:case("BinaryString preserves null and non-UTF-8 bytes", function(asserts: Asserts)
		local v, status = serializeProperty("BinaryString", "\0\255")
		asserts.eq("ok", status)
		asserts.eq({ BinaryString = "AP8=" }, v)
	end)

	suite:case("Font", function(asserts: Asserts)
		local v, status = serializeProperty("Font", {
			Family = "rbxasset://fonts/families/LegacyArial.json",
			Weight = { Name = "Regular" },
			Style = { Name = "Normal" },
		})
		asserts.eq("ok", status)
		asserts.eq({
			family = "rbxasset://fonts/families/LegacyArial.json",
			weight = "Regular",
			style = "Normal",
		}, v)
	end)

	suite:case("Enum.NormalId serializes to its Name", function(asserts: Asserts)
		local v, status = serializeProperty("Enum.NormalId", { Name = "Top" })
		asserts.eq("ok", status)
		asserts.eq("Top", v)
	end)

	suite:case("Enum.SurfaceType", function(asserts: Asserts)
		local v, status = serializeProperty("Enum.SurfaceType", { Name = "Smooth" })
		asserts.eq("ok", status)
		asserts.eq("Smooth", v)
	end)

	suite:case("Enum.Material", function(asserts: Asserts)
		local v, status = serializeProperty("Enum.Material", { Name = "Plastic" })
		asserts.eq("ok", status)
		asserts.eq("Plastic", v)
	end)

	suite:case("Ref skipped silently", function(asserts: Asserts)
		local v, status = serializeProperty("Ref", { ClassName = "Part" })
		asserts.eq("skipped", status)
		asserts.eq(nil, v)
	end)

	suite:case("Unknown datatype reports unsupported", function(asserts: Asserts)
		local v, status = serializeProperty("Unknown", { Something = 0.5 })
		asserts.eq("unsupported", status)
		asserts.eq(nil, v)
	end)

	suite:case("Every SERIALIZERS entry has a matching test case", function(asserts: Asserts)
		local tested = {
			Bool = true,
			String = true,
			Int32 = true,
			Int64 = true,
			Float32 = true,
			Float64 = true,
			Vector2 = true,
			Vector3 = true,
			UDim2 = true,
			NumberRange = true,
			NumberSequence = true,
			BrickColor = true,
			Color3 = true,
			ColorSequence = true,
			CFrame = true,
			OptionalCFrame = true,
			Content = true,
			ContentId = true,
			PhysicalProperties = true,
			BinaryString = true,
			Font = true,
		}
		for datatype in SERIALIZERS do
			asserts.eq(true, tested[datatype])
		end
	end)
end)
