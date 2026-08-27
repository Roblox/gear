--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

Parts = {}

BaseColor = BrickColor.new("Bright yellow")
Color = BaseColor.Color

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		Reflectance = 0.5,
		TopSurface = Enum.SurfaceType.SmoothNoOutlines,
		BottomSurface = Enum.SurfaceType.SmoothNoOutlines,
		FrontSurface = Enum.SurfaceType.SmoothNoOutlines,
		BackSurface = Enum.SurfaceType.SmoothNoOutlines,
		LeftSurface = Enum.SurfaceType.SmoothNoOutlines,
		RightSurface = Enum.SurfaceType.SmoothNoOutlines,
		Anchored = true,
		CanCollide = true,
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

Gravity = 196.20

Duration = 10

Objects = {}
RemovedObjects = {}
FakeParts = {}
Hats = {}
Tools = {}

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Weld(Parent, PrimaryPart)
	local Parts = {}
	local Welds = {}
	local function WeldModel(Parent, PrimaryPart)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				if v ~= PrimaryPart then
					local Weld = Instance.new("Weld")
					Weld.Name = "Weld"
					Weld.Part0 = PrimaryPart
					Weld.Part1 = v
					Weld.C0 = PrimaryPart.CFrame:inverse()
					Weld.C1 = v.CFrame:inverse()
					Weld.Parent = PrimaryPart
					table.insert(Welds, Weld)
				end
				table.insert(Parts, v)
			end
			WeldModel(v, PrimaryPart)
		end
	end
	WeldModel(Parent, PrimaryPart)
	return Parts, Welds
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

if not Humanoid then
	DestroyScriot()
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
				FakePart.Name = "Hat"
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

FakeModel = Instance.new("Model")
FakeModel.Name = Character.Name
for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		local FakePart = v:Clone()
		for ii, vv in pairs(FakePart:GetChildren()) do
			if not vv:IsA("DataModelMesh") then
				vv:Destroy()
			end
		end
		v:Destroy()
		FakePart.Parent = FakeModel
	end
end

local Torso = FakeModel:FindFirstChild("Torso")
if Torso then
	local Parts, Welds = Weld(FakeModel, Torso)
	for i, v in pairs(Parts) do
		if v and v.Parent then
			if v.Name == "Hat" then
				v.CanCollide = false
			end
			v.Anchored = false
		end
	end
	local Mass = 0
	local Speed = 10
	local ConnectedParts = GetAllConnectedParts(Torso)
	for i, v in pairs(ConnectedParts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity)
	--[[local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = (Vector3.new(Mass, Mass, Mass) * Speed)
	BodyGyro.Parent = Torso
	Delay(3, (function()
		if BodyGyro and BodyGyro.Parent then
			BodyGyro.cframe = Torso.CFrame * CFrame.Angles(-(math.pi / 2), 0, 0)
		end
	end))]]
end

Debris:AddItem(FakeModel, Duration)
FakeModel.Parent = game:GetService("Workspace")