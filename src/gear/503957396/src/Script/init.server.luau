--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

LightningFunctions = require(script:WaitForChild("LightningFunctions"))
StunScript = script:WaitForChild("StunScript")

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

BaseSlime = BasePart:Clone()
BaseSlime.Name = "Slime"
BaseSlime.BrickColor = BrickColor.new("Lime green")
BaseSlime.Size = Vector3.new(0.5, 1.25, 0.5)
BaseSlime.CanCollide = false
SlimeMesh = Instance.new("CylinderMesh")
SlimeMesh.Scale = (Vector3.new(1, 1, 1) * BaseSlime.Size)
SlimeMesh.VertexColor = Vector3.new(1, 1, 1)
SlimeMesh.Offset = Vector3.new(0, 0, 0)
SlimeMesh.Parent = BaseSlime

Animations = {}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

ReloadTime  = 1.25

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function CreateDisplay(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	Mesh.MeshId = (BaseUrl .. ((Create and "502811607") or "502811730"))
	if not Create then
		return
	end
	local BigCoil = BasePart:Clone()
	BigCoil.Name = "BigCoil"
	local CoilMesh = Instance.new("SpecialMesh")
	CoilMesh.Name = "Mesh"
	CoilMesh.MeshType = Enum.MeshType.FileMesh
	CoilMesh.MeshId = (BaseUrl .. "502811563")
	CoilMesh.TextureId = (BaseUrl .. "502811337")
	CoilMesh.Scale = Mesh.Scale
	CoilMesh.VertexColor = Vector3.new(1, 1, 1)
	CoilMesh.Offset = Vector3.new(0, 0, 0)
	CoilMesh.Parent = BigCoil
	BigCoilMotor = Instance.new("Motor6D")
	BigCoilMotor.Name = "Motor"
	BigCoilMotor.Part0 = Handle
	BigCoilMotor.Part1 = BigCoil
	BigCoilMotor.C0 = CFrame.new(0, 0.405, -0.585)
	BigCoilMotor.C1 = CFrame.new(0, 0, 0)
	--BigCoilMotor.MaxVelocity = 0.1
	BigCoilMotor.CurrentAngle = 0
	BigCoilMotor.DesiredAngle = 999999999
	BigCoilMotor.Parent = BigCoil
	local SmallCoil = BigCoil:Clone()
	SmallCoil.Name = "SmallCoil"
	SmallCoil.Mesh.MeshId = (BaseUrl .. "502811659")
	SmallCoilMotor = SmallCoil.Motor
	SmallCoilMotor.C0 = CFrame.new(0, 0.425, 0.495)
	BigCoil.Parent = Tool
	SmallCoil.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Sounds.Fire.Pitch = (math.random(1250, 2500) * 0.001)
	Sounds.Fire:Play()
	local StartPosition = (Handle.CFrame * CFrame.new(0, ((Handle.Size.Y / 3)), -((Handle.Size.Z / 2) - 0))).p
	local TargetPosition = MouseData.Position
	LightningFunctions.RemoveLightning()
	local HitData = LightningFunctions.Zap({StartPosition = StartPosition, TargetPosition = TargetPosition, Character = Character, Color = "Cyan", Individual = false, Duration = 2, TimeToFade = 0.375, MaxRange = 30, SegmentLength = 1.25, Thickness = 0.75, Ignore = {Character}})
	Spawn(function()
		if not HitData or not HitData.RayHit then
			return
		end
		local Hit = HitData.RayHit
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player == Player or IsTeamMate(Player, player) then
			return
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local StunScriptCopy = character:FindFirstChild(StunScript.Name)
		if not StunScriptCopy then
			StunScriptCopy = StunScript:Clone()
			local Duration = Instance.new("NumberValue")
			Duration.Name = "Duration"
			Duration.Value = 2
			Duration.Parent = StunScriptCopy
			StunScriptCopy.Disabled = false
			StunScriptCopy.Parent = character
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(15)
	end)
	Spawn(function()
		for i, v in pairs({BigCoilMotor, SmallCoilMotor}) do
			v.MaxVelocity = 1
		end
		local DecreaseRate = 100
		local WaitRate = 0.03
		local FireSound = Sounds.Fire
		local MotorDecreaseAmount = (BigCoilMotor.MaxVelocity / DecreaseRate)
		local FireVolume = (FireSound.Volume / DecreaseRate)
		local FirePitch = (FireSound.Pitch / DecreaseRate)
		for i = 1, DecreaseRate do
			local DecreaseAmount = (DecreaseRate - i)
			for ii, vv in pairs({SmallCoilMotor, BigCoilMotor}) do
				vv.MaxVelocity = (MotorDecreaseAmount * DecreaseAmount)
			end
			wait(WaitRate)
		end
	end)
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateDisplay(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		CreateDisplay(false)
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateDisplay(false)
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)