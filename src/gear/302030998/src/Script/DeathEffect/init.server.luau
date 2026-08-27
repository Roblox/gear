--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

WindDirection = script:FindFirstChild("WindDirection")
Force = script:FindFirstChild("Force")

SoulEffect = script:FindFirstChild("SoulEffect")

BaseColor = BrickColor.new("Institutional white")
Color = BaseColor.Color

Gravity = 196.20

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BannedProperties = {"Enabled", "Disabled"}

Classes = {
	BasePart = {
		BrickColor = BaseColor,
		Material = Enum.Material.SmoothPlastic,
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
DisplayParts = {}
Hats = {}
Tools = {}

Rate = (1 / 60)

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
			elseif Object:IsA("Clothing") then
				Object:Destroy()
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

function Weld(Parent, PrimaryPart)
	local Parts = {}
	local function WeldModel(Parent, PrimaryPart)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") and v ~= PrimaryPart then
				local Weld = Instance.new("Weld")
				Weld.Name = "Weld"
				Weld.Part0 = PrimaryPart
				Weld.Part1 = v
				Weld.C0 = PrimaryPart.CFrame:inverse()
				Weld.C1 = v.CFrame:inverse()
				Weld.Parent = v
				table.insert(Parts, v)
			end
			Weld(v, PrimaryPart)
		end
	end
	WeldModel(Parent, PrimaryPart)
	return Parts
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

local FakeModel = Instance.new("Model")
FakeModel.Name = "Ghost"

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("Hat") or v:IsA("Tool") then
		local FakeObject = v:Clone()
		Decorate(FakeObject)
		table.insert(((v:IsA("Hat") and Hats) or Tools), v)
		for ii, vv in pairs(FakeObject:GetChildren()) do
			if vv:IsA("BasePart") then
				if vv.Transparency < 1 then
					local FakePart = vv:Clone()
					FakePart.Name = v.Name
					table.insert(FakeParts, FakePart)
					FakePart.Parent = FakeModel
					FakePart.CFrame = vv.CFrame
				end
			end
		end
	elseif v:IsA("BasePart") then
		if v.Transparency >= 1 then
			v:Destroy()
		end
	end
end

Player = Players:GetPlayerFromCharacter(Character)
if Player then
	Humanoid:UnequipTools()
end

for i, v in pairs({Hats, Tools}) do
	for ii, vv in pairs(v) do
		vv.Parent = nil
	end
end

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		local FakePart = v:Clone()
		FakePart.CanCollide = false
		for ii, vv in pairs(FakePart:GetChildren()) do
			if not vv:IsA("DataModelMesh") then
				vv:Destroy()
			end
		end
		for ii,vv in pairs(Character:GetChildren()) do
			if vv:IsA("CharacterMesh") and string.gsub(v.Name, " ", "") == vv.BodyPart.Name then
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = (BaseUrl .. vv.MeshId)
				Mesh.TextureId = (BaseUrl .. vv.BaseTextureId)
				Mesh.Scale = Vector3.new(1, 1, 1)
				Mesh.Offset = Vector3.new(0, 0, 0)
				Mesh.VertexColor = Vector3.new(1, 1, 1)
				Mesh.Parent = FakePart
			end
		end
		FakePart.Parent = FakeModel
		v:Destroy()
	end
end

for i, v in pairs(FakeModel:GetChildren()) do
	if v and v.Parent and v:IsA("BasePart") then
		local Mass = (v:GetMass() * Gravity ^ 2)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyVelocity.velocity = (WindDirection.Value * Force.Value)
		BodyVelocity.Parent = v
		for ii, vv in pairs(v:GetChildren()) do
			local PropertyExists = false
			for iii, vvv in pairs(BannedProperties) do
				pcall(function()
					local Property = vv[vvv]
					PropertyExists = true
				end)
			end
			if PropertyExists then
				vv:Destroy()
			end
		end
		if v.Name == "Torso" then
			if SoulEffect then
				local SoulEffectCopy = SoulEffect:Clone()
				SoulEffectCopy.Enabled = true
				SoulEffectCopy.Parent = v
			end
		end
		v.Name = "Effect"
		table.insert(DisplayParts, v)
	end
end

Delay(0.25, (function()
	local FadeRate = 50
	for i = 1, ((1 - Classes.BasePart.Transparency) * (1 * FadeRate)) do
		for ii, vv in pairs(DisplayParts) do
			if vv and vv.Parent then 
				vv.Transparency = (vv.Transparency + (1 / FadeRate))
			end
		end
		wait(Rate)
	end
	if FakeModel and FakeModel.Parent then
		FakeModel:Destroy()
	end
end))

Redesign(FakeModel)

BoundaryBox = BasePart:Clone()
BoundaryBox.Name = "Effect"
BoundaryBox.Transparency = 1
BoundaryBox.CanCollide = false
BoundaryBox.Size = FakeModel:GetModelSize()
BoundaryBox.CFrame = FakeModel:GetModelCFrame()
BoundaryBox.Parent = FakeModel

Weld(FakeModel, BoundaryBox)

Debris:AddItem(FakeModel, 10)
FakeModel.Parent = game:GetService("Workspace")