--Rescripted by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator").Value
Center = script:WaitForChild("Center").Value

Range = 200

Objects = {}

StonifyTag = Instance.new("BoolValue")
StonifyTag.Name = "StoneStaffStonified"

PartColor = BrickColor.new("Medium stone grey")
Color = PartColor.Color
Material = Enum.Material.Slate
VertexColor = Vector3.new(Color.r, Color.g, Color.b)
Texture = "http://www.roblox.com/asset/?id=58972839"--"rbxasset://Textures/SlateTileMono.png"

Properties = {
	CharacterMesh = {
		BaseTextureId = Texture,
		OverlayTextureId = Texture,
	},
	BasePart = {
		BrickColor = PartColor,
		Material = Material
	},
	DataModelMesh = {
		VertexColor = VertexColor
	},
	FileMesh = {
		TextureId = Texture,
		VertexColor = Vector3.new(1, 1, 1)
	},
}

function Stonify(Object)
	local StonifiedObjects = {}
	local function SetProperties(Object)
		local ObjectProperties = {}
		for i, v in pairs(Properties) do
			for ii, vv in pairs(v) do
				local PropertyExists = false
				pcall(function()
					local PropertyValue = Object[ii]
					PropertyExists = true
				end)
				if PropertyExists then
					if not Object:IsA("SpecialMesh") or Object.MeshType == Enum.MeshType.FileMesh then
						table.insert(ObjectProperties, {Property = ii, Value = Object[ii]})
						Object[ii] = vv
					end
				end
			end
		end
		return ((ObjectProperties ~= {} and ObjectProperties) or nil)
	end
	local function StonifyObject(Object)
		local ObjectProperties = SetProperties(Object)
		if ObjectProperties then
			table.insert(StonifiedObjects, {Object = Object, Properties = ObjectProperties})
		end
		if Object:IsA("BasePart") then
			for i, v in pairs(Object:GetChildren()) do
				StonifyObject(v)
			end
		end
	end
	StonifyObject(Object)
	return StonifiedObjects
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Origin, Radius, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region3.new((Origin - Vector3.new(Radius, Radius, Radius)), (Origin + Vector3.new(Radius, Radius, Radius)))
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

Parts = {((Creator and Creator and Creator.Parent and Creator:IsA("Player") and Creator.Character) and Creator.Character)}

for i, v in pairs(Players:GetChildren()) do
	if v:IsA("Player") and v.Character then
		table.insert(Parts, v.Character)
	end
end

for CurrentRange = 1, Range, 1 do
	local StonifiedObjects = {}
	for i, v in pairs(GetParts(Center, CurrentRange, 500, Parts)) do
		local player = Players:GetPlayerFromCharacter(v.Parent)
		if not player then
			table.insert(Parts, v)
			table.insert(StonifiedObjects, Stonify(v))
		end
	end
	table.insert(Objects, StonifiedObjects)
	wait(1 / 30)
end

local NewObjects = {}
for i, v in pairs(Objects) do
	NewObjects[#Objects - (i - 1)] = v
end
Objects = NewObjects

for i, v in pairs(Objects) do
	for ii, vv in pairs(v) do
		for iii, vvv in pairs(vv) do
			if vvv.Object then
				for iiii, vvvv in pairs(vvv.Properties) do
					vvv.Object[vvvv.Property] = vvvv.Value
				end
			end
		end
	end
	wait(1 / 30)
end

Debris:AddItem(script, 0)