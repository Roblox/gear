--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

WindDirection = script:FindFirstChild("WindDirection")
Force = script:FindFirstChild("Force")

Parts = {}

BaseColor = BrickColor.new("Really red")
Color = BaseColor.Color

Gravity = 196.20

Duration = 3

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.Plastic,
		Reflectance = 0,
		Transparency = 0.75,
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
		Enabled = false,
	},
	Fire = {
		Color = Color,
		SecondaryColor = Color,
		Enabled = false,
	},
	Smoke = {
		Color = Color,
		Enabled = false,
	},
	Light = {
		Color = Color,
		Enabled = false,
	},
	ParticleEmitter = {
		Color = ColorSequence.new(Color, Color),
		Enabled = false,
	}
}

Fire = script:FindFirstChild("Fire")

Objects = {}
RemovedObjects = {}
FakeParts = {}
Hats = {}
Tools = {}
Particles = {}

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

function TweenNumber(Start, Goal, Time)
	return ((Goal - Start) / Time)
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
			elseif Object:IsA("BasePart") and Object.Transparency >= 1 then
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

local GhostModel = Instance.new("Model")
GhostModel.Name = "GhostModel"

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		if v.Name ~= "HumanoidRootPart" then
			local FakePart = v:Clone()
			FakePart.Name = "Part"
			FakePart.CanCollide = false
			for ii, vv in pairs(FakePart:GetChildren()) do
				if not vv:IsA("DataModelMesh") then
					vv:Destroy()
				end
			end
			table.insert(FakeParts, FakePart)
			local Mass = (v:GetMass() * Gravity ^ 2)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.velocity = (WindDirection.Value * Force.Value)
			BodyVelocity.Parent = FakePart
			FakePart.Parent = GhostModel
			local FireParticle = Fire:Clone()
			FireParticle.Enabled = true
			table.insert(Particles, FireParticle)
			FireParticle.Parent = FakePart
		end
		v:Destroy()
	end
end

Spawn(function()
	local Start = Classes.BasePart.Transparency
	local End = 1
	local Time = 0.75
	local Rate = (1 / 30)
	local Frames = (Time / Rate)
	for i = 1, Frames do
		local Transparency = (Start + TweenNumber(Start, End, (Frames / (i + 1))))
		for ii, vv in pairs(FakeParts) do
			if vv and vv.Parent then
				vv.Transparency = Transparency
			end
		end
		wait(Rate)
	end
	for i, v in pairs(Particles) do
		v.Enabled = false
	end
end)

Debris:AddItem(GhostModel, 5)
GhostModel.Parent = game:GetService("Workspace")