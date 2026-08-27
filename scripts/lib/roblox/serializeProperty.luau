--[[
	Serialize a Roblox property value to its Rojo project-file form, keyed
	on the canonical reflection `Datatype` (e.g. `Vector3`, `Enum.Material`).
	See https://rojo.space/docs/v7/properties/ for the format reference.

	Returns:
		(value, "ok")          - serialized
		(nil,   "skipped")     - intentionally not serialized (only `Ref` today)
		(nil,   "unsupported") - no handler; caller should warn so we add one

	Scope is intentionally minimal: only the datatypes the existing dumped
	gear actually emit. Add more (UDim2, BrickColor, NumberSequence, ...)
	when a new intake surfaces them as `unsupported`.
]]

export type Status = "ok" | "skipped" | "unsupported"

type Serializer = (value: any) -> any

local function identity(value: any): any
	return value
end

local SERIALIZERS: { [string]: Serializer } = {
	Bool = identity,
	String = identity,
	Int32 = identity,
	Int64 = identity,
	Float32 = identity,
	Float64 = identity,
	Vector2 = function(v)
		return { v.X, v.Y }
	end,
	Vector3 = function(v)
		return { v.X, v.Y, v.Z }
	end,
	UDim2 = function(v)
		return {
			UDim2 = {
				{ v.X.Scale, v.X.Offset },
				{ v.Y.Scale, v.Y.Offset },
			},
		}
	end,
	NumberRange = function(v)
		return { NumberRange = { v.Min, v.Max } }
	end,
	NumberSequence = function(v)
		local keypoints = {}
		for _, keypoint in v.Keypoints do
			table.insert(keypoints, {
				time = keypoint.Time,
				value = keypoint.Value,
				envelope = keypoint.Envelope,
			})
		end
		return { NumberSequence = { keypoints = keypoints } }
	end,
	Color3 = function(v)
		return { v.R, v.G, v.B }
	end,
	BrickColor = function(v)
		return { BrickColor = v.Number }
	end,
	ColorSequence = function(v)
		local keypoints = {}
		for _, keypoint in v.Keypoints do
			table.insert(keypoints, {
				time = keypoint.Time,
				color = { keypoint.Value.R, keypoint.Value.G, keypoint.Value.B },
			})
		end
		return { ColorSequence = { keypoints = keypoints } }
	end,
	CFrame = function(v)
		return { v:GetComponents() }
	end,
	-- Rojo rejects the flat twelve-number shorthand here and only accepts a
	-- tagged CFrame in its explicit position/orientation form.
	OptionalCFrame = function(v)
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = v:GetComponents()
		return {
			OptionalCFrame = {
				position = { x, y, z },
				orientation = { { r00, r01, r02 }, { r10, r11, r12 }, { r20, r21, r22 } },
			},
		}
	end,
	Content = function(v)
		return if type(v) == "string" then v else v.Uri
	end,
	ContentId = function(v)
		return if type(v) == "string" then v else v.Uri
	end,
}

-- `Ref` (Welds, Parent, ...) isn't representable in Rojo project files yet;
-- silence it so dumps aren't drowned in warnings on every Instance.
local SKIPPED: { [string]: boolean } = { Ref = true }

local function serializeProperty(datatype: string, value: any): (any, Status)
	local serializer = SERIALIZERS[datatype]
	if serializer then
		return serializer(value), "ok"
	end
	-- Reflection scopes every enum as `Enum.<name>`; one branch covers all.
	if string.sub(datatype, 1, 5) == "Enum." then
		return value.Name, "ok"
	end
	if SKIPPED[datatype] then
		return nil, "skipped"
	end
	return nil, "unsupported"
end

return {
	serializeProperty = serializeProperty,
	SERIALIZERS = SERIALIZERS,
	SKIPPED = SKIPPED,
}
