--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

EggModule = require(225918694)

BaseUrl = "http://www.roblox.com/asset/?id="

LaunchScript = script:WaitForChild("LaunchScript"):Clone()

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

FakeEggSpawner = BasePart:Clone()
FakeEggSpawner.Name = "FakeEggSpawner"
FakeEggSpawner.Size = Vector3.new(1.5, 0.25, 1.5)
FakeEggSpawnerMesh = Instance.new("SpecialMesh")
FakeEggSpawnerMesh.Name = "Mesh"
FakeEggSpawnerMesh.MeshType = Enum.MeshType.FileMesh
FakeEggSpawnerMesh.MeshId = (BaseUrl .. "225550011")
FakeEggSpawnerMesh.TextureId = (BaseUrl .. "225550079")
FakeEggSpawnerMesh.Scale = Vector3.new(0.3, 0.3, 0.3)
FakeEggSpawnerMesh.VertexColor = Vector3.new(1, 1, 1)
FakeEggSpawnerMesh.Offset = Vector3.new(0, 0, 0)
FakeEggSpawnerMesh.Parent = FakeEggSpawner

Gravity = 196.20

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local SpawnerName = (Player.Name .. "'s" .. FakeEggSpawner.Name)
	local CurrentFakeEggSpawner = game:GetService("Workspace"):FindFirstChild(SpawnerName)
	if CurrentFakeEggSpawner then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	local FakeEggSpawnerClone = FakeEggSpawner:Clone()
	FakeEggSpawnerClone.Name = SpawnerName
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = FakeEggSpawnerClone
	local AngleX, AngleY, AngleZ = Handle.CFrame:toEulerAnglesXYZ()
	local PartCFrame = CFrame.new(Handle.Position, (Handle.CFrame + Head.CFrame.lookVector * 2).p)
	--[[local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = PartCFrame
	BodyGyro.Parent = FakeEggSpawnerClone]]
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(0, (FakeEggSpawnerClone:GetMass() * Gravity), 0)
	BodyVelocity.velocity = (Vector3.new(0, -1, 0) * 35)
	BodyVelocity.Parent = FakeEggSpawnerClone
	local LaunchScriptClone = LaunchScript:Clone()
	LaunchScriptClone.Disabled = false
	LaunchScriptClone.Parent = FakeEggSpawnerClone
	Debris:AddItem(FakeEggSpawnerClone, (Duration + ChanceToStick))
	FakeEggSpawnerClone.CFrame = PartCFrame
	FakeEggSpawnerClone.Parent = game:GetService("Workspace")
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function GetVariables(Player)
	local Gear = EggModule.GetGear({Key = "FakeEggSpawner", Player = Player})
	Duration = Gear.Duration
	ChanceToStick = Gear.ChanceToStick
	ReloadTime = Gear.ReloadTime
end

function Equipped()
	Character = Tool.Parent
	Humanoid = nil
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Humanoid") then
			Humanoid = v
			break
		end
	end
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = ((Tool.Enabled and 0) or 1)
	Spawn(function()
		GetVariables(Player)
	end)
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)