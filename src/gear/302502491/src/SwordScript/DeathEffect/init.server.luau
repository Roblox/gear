--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

WindDirection = script:WaitForChild("WindDirection")
Force = script:WaitForChild("Force")
Functions = require(script:WaitForChild("Functions"))

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

DisplayParts = {}

Rate = (1 / 60)

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Humanoid then
	DestroyScript()
	return
end

local FakeModel = Instance.new("Model")
FakeModel.Name = "Ghost"

Objects = Functions.Redesign(Character)

for i, v in pairs(Objects) do
	v = v.Object
	if v:IsA("BasePart") then
		local FakePart = v:Clone()
		FakePart.CanCollide = false
		for ii, vv in pairs(FakePart:GetChildren()) do
			if vv:IsA("JointInstance") then
				vv:Destroy()
			end
		end
		for ii, vv in pairs(Objects) do
			vv = vv.Object
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

Objects = Functions.Redesign(FakeModel)

for i, v in pairs(Objects) do
	v = v.Object
	if v:IsA("BasePart") then
		local Mass = (v:GetMass() * Gravity ^ 2)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyVelocity.velocity = (WindDirection.Value * Force.Value)
		BodyVelocity.Parent = v
		if v.Name == "Torso" or v.Name == "UpperTorso" then
		end
		v.Name = "Effect"
		if v.Transparency < 1 then
			table.insert(DisplayParts, v)
		end
	elseif v:IsA("Decal") or v:IsA("Texture") then
		if v.Transparency < 1 then
			table.insert(DisplayParts, v)
		end
	end
end

Delay(0.1, (function()
	local FadeRate = 30
	for i = 1, ((1 - Functions.DarkProperties.All.Transparency) * (1 * FadeRate)) do
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

BoundaryBox = BasePart:Clone()
BoundaryBox.Name = "Effect"
BoundaryBox.Transparency = 1
BoundaryBox.CanCollide = false
BoundaryBox.Size = FakeModel:GetModelSize()
BoundaryBox.CFrame = FakeModel:GetModelCFrame()
BoundaryBox.Parent = FakeModel

Functions.Weld(FakeModel, BoundaryBox)

Debris:AddItem(FakeModel, 10)
FakeModel.Parent = game:GetService("Workspace")