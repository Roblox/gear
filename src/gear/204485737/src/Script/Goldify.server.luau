--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

BaseColor = BrickColor.new("Bright yellow")
Color = BaseColor.Color

Duration = 15

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		Reflectance = 0.5,
		Anchored = true,
	},
	FileMesh = {
		TextureId = "",
	},
	DataModelMesh = {
		VertexColor = Vector3.new(Color.r, Color.g, Color.b),
	},
	CharacterMesh = {
		BaseTextureId = 0,
		OverlayTextureId = 0,
	},
	Shirt = {
		ShirtTemplate = "",
	},
	Pants = {
		PantsTemplate = "",
	},
	FaceInstance = {
		Texture = "",
	},
	Sparkles = {
		SparkleColor = Color,
	},
	Fire = {
		Color = Color,
		SecondaryColor = Color,
	},
	Smoke = {
		Color = Color,
	}
}

Objects = {}
RemovedObjects = {}
FakeParts = {}
Hats = {}
Tools = {}

function Decorate(Object)
	local ObjectData = {
		Object = nil,
		Properties = {},
	}
	for i, v in pairs(Classes) do
		if Object:IsA(i) then
			if Object:IsA("CharacterMesh") then
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = ("http://www.roblox.com/asset/?id=" .. Object.MeshId)
				for ii, vv in pairs(Character:GetChildren()) do
					if vv:IsA("BasePart") and Object.BodyPart.Name == string.gsub(vv.Name, " ", "") then
						Mesh.Parent = vv
						table.insert(RemovedObjects, {Object = Object, NewObject = Mesh, Parent = Object.Parent})
						Object.Parent = nil
					end
				end
			else
				ObjectData.Object = Object
				for ii, vv in pairs(v) do
					local PropertyValue = nil
					local PropertyValueSet = false
					pcall(function()
						PropertyValue = Object[ii]
						PropertyValueSet = true
						Object[ii] = vv
					end)
					if PropertyValueSet then
						ObjectData.Properties[ii] = PropertyValue
					end
				end
			end
		end
	end
	table.insert(Objects, ObjectData)
end

function Redesign(Parent)
	for i, v in pairs(Parent:GetChildren()) do
		Decorate(v)
		Redesign(v)
	end
end

for i, v in pairs(Character:GetChildren()) do --Create fake hats and tools, and goldify them
	if v:IsA("Hat") or v:IsA("Tool") then
		local FakeObject = v:Clone()
		Decorate(FakeObject)
		table.insert(((v:IsA("Hat") and Hats) or Tools), v)
		for ii, vv in pairs(FakeObject:GetChildren()) do
			if vv:IsA("BasePart") then
				local FakePart = vv:Clone()
				FakePart.Name = v.Name
				table.insert(FakeParts, FakePart)
				FakePart.Parent = Character
				FakePart.CFrame = vv.CFrame
			end
		end
	end
end

if Humanoid and Humanoid.Parent then
	Humanoid:UnequipTools()
end

for i, v in pairs({Hats, Tools}) do
	for ii, vv in pairs(v) do
		vv.Parent = nil
	end
end

Redesign(Character) --Goldify the player

wait(Duration)

for i, v in pairs(Objects) do --Ungoldify the player
	for ii, vv in pairs(v.Properties) do
		v.Object[ii] = vv
	end
end
for i, v in pairs(RemovedObjects) do
	if v.NewObject and v.NewObject.Parent then
		v.NewObject:Destroy()
	end
	v.Object.Parent = v.Parent
end
for i, v in pairs(FakeParts) do
	if v and v.Parent then
		v:Destroy()
	end
end
for i, v in pairs(Hats) do
	v.Parent = Character
end
for i, v in pairs(Tools) do
	if Humanoid and Humanoid.Parent then
		Humanoid:EquipTool(v)
	else
		v.Parent = Character
	end
end

script:Destroy()