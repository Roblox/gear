--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

Creator = script:WaitForChild("Creator")
Player = Creator.Value

Debris = game:GetService("Debris")

function GatherAllInstances(Parent)
	local Instances = {}
	local function GatherInstances(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GatherInstances(v)
			table.insert(Instances, v)
		end
	end
	GatherInstances(Parent)
	return Instances
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

for i, v in pairs(GatherAllInstances(Character)) do
	if not v.Parent:IsA("Tool") and not v.Parent.Parent:IsA("Tool") then
		if v:IsA("BasePart") then
			v.BrickColor = BrickColor.new("Lime green")
		elseif v:IsA("CharacterMesh") then
			v.BaseTextureId = 0
			v.OverlayTextureId = 0
		elseif v:IsA("DataModelMesh") then
			if v:IsA("SpecialMesh") then
				v.TextureId = ""
			end
			local BrickColor = BrickColor.new("Lime green")
			local Color = BrickColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
		elseif v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("Decal") and v.Name ~= "face" then
			v:Destroy()
		end
	end
end

Humanoid.Changed:connect(function()
	Humanoid.Jump = false
end)

wait(5)

for i = 1, 100 do
	Humanoid.WalkSpeed = Humanoid.WalkSpeed - (Humanoid.WalkSpeed / 100)
	wait()
end

UntagHumanoid(Humanoid)
TagHumanoid(Humanoid, Player)

Slime = Instance.new("Part")
Slime.Name = "GreenSlime"
Slime.Anchored = true
Slime.CanCollide = false
Slime.Locked = true
Slime.Material = Enum.Material.Plastic
Slime.Shape = Enum.PartType.Block
Slime.TopSurface = Enum.SurfaceType.Smooth
Slime.BottomSurface = Enum.SurfaceType.Smooth
Slime.FormFactor = Enum.FormFactor.Custom
Slime.Size = Vector3.new(5.75, 0.75, 4.5)
SlimeMesh = Instance.new("SpecialMesh")
SlimeMesh.MeshType = Enum.MeshType.FileMesh
SlimeMesh.MeshId = "http://www.roblox.com/asset?id=153993912"
SlimeMesh.TextureId = "http://www.roblox.com/asset?id=153993940"
SlimeMesh.Scale = Vector3.new(3, 2, 3)
SlimeMesh.Parent = Slime
Debris:AddItem(Slime, 10)
Slime.Parent = game:GetService("Workspace")
Slime.CFrame = Character:GetModelCFrame() - Vector3.new(0, ((Character:GetModelSize().Y / 2) - (Slime.Size.Y / 2)), 0)

Humanoid.Health = 0

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		v:Destroy()
	end
end