--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BoothManagerScript = script:WaitForChild("BoothManager")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Booth = BasePart:Clone()
Booth.Name = "Booth"
Booth.Size = Vector3.new(1.5, 0.25, 1.5)
Booth.Friction = 2
Booth.Elasticity = 0
BoothMesh = Instance.new("SpecialMesh")
BoothMesh.Name = "Mesh"
BoothMesh.MeshType = Enum.MeshType.FileMesh
BoothMesh.MeshId = (BaseUrl .. "313500859")
BoothMesh.TextureId = (BaseUrl .. "313500947")
BoothMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
BoothMesh.VertexColor = Vector3.new(1, 1, 1)
BoothMesh.Offset = Vector3.new(0, 0, 0)
BoothMesh.Parent = Booth

Gravity = 196.20

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function CheckUsability()
	local CurrentBooth = game:GetService("Workspace"):FindFirstChild(SpawnerName)
	Handle.Transparency = ((CurrentBooth and 1) or 0)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local CurrentBooth = game:GetService("Workspace"):FindFirstChild(SpawnerName)
	if CurrentBooth then
		CurrentBooth:Destroy()
		CheckUsability()
		return
	else
		Tool.Enabled = false
		local BoothClone = Booth:Clone()
		BoothClone.Name = SpawnerName
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = BoothClone
		local PartCFrame = CFrame.new(Handle.Position, (Handle.CFrame + Torso.CFrame.lookVector * 2).p)
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.cframe = PartCFrame
		BodyGyro.Parent = BoothClone
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(0, (BoothClone:GetMass() * Gravity), 0)
		BodyVelocity.velocity = (Vector3.new(0, -1, 0) * 50)
		BodyVelocity.Parent = BoothClone
		local BoothManagerScriptClone = BoothManagerScript:Clone()
		BoothManagerScriptClone.Disabled = false
		BoothManagerScriptClone.Parent = BoothClone
		BoothClone.CFrame = PartCFrame
		BoothClone.Parent = game:GetService("Workspace")
		CheckUsability()
		wait(2)
		CheckUsability()
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	SpawnerName = (Player.Name .. "'s" .. Booth.Name)
	CheckUsability()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((Tool.Enabled and 0) or 1)) or 0)
		if ToolEquipped then
			CheckUsability()
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)