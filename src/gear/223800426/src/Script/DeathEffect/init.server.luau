--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

WindDirection = script:FindFirstChild("WindDirection")
Force = script:FindFirstChild("Force")

Parts = {}

BaseColor = BrickColor.new("Really black")
Color = BaseColor.Color

Gravity = 196.20

Duration = 3

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.Concrete,
		Reflectance = 0,
		Transparency = 0.5,
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

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

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
		if v ~= script then
			Decorate(v)
			Redesign(v)
		end
	end
end

if not Humanoid or not WindDirection then
	DestroyScript()
	return
end

for i, v in pairs(Character:GetChildren()) do
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

Humanoid:UnequipTools()

for i, v in pairs({Hats, Tools}) do
	for ii, vv in pairs(v) do
		vv.Parent = nil
	end
end

Redesign(Character)

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		local FakePart = v:Clone()
		FakePart.Name = "Part"
		FakePart.CanCollide = false
		for ii, vv in pairs(FakePart:GetChildren()) do
			if not vv:IsA("DataModelMesh") then
				vv:Destroy()
			end
		end
		local Mass = (v:GetMass() * Gravity ^ 2)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyVelocity.velocity = (WindDirection.Value * Force.Value)
		BodyVelocity.Parent = FakePart
		Debris:AddItem(FakePart, 3)
		v:Destroy()
		FakePart.Parent = game:GetService("Workspace")
	end
end