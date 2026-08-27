--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BeamModel = InsertService:LoadAsset(243879490)
Beam = BeamModel:GetChildren()[1]:Clone()
Debris:AddItem(BeamModel, 1)

Functions = require(script:WaitForChild("Functions"))

BaseUrl = "http://www.roblox.com/asset/?id="

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

BaseLaser = BasePart:Clone()
BaseLaser.Name = "Laser"
BaseLaser.Material = Enum.Material.SmoothPlastic
BaseLaser.Size = Vector3.new(1, 1, 1)
BaseLaser.Anchored = true
BaseLaser.CanCollide = false
BaseLaserMesh = Instance.new("SpecialMesh")
BaseLaserMesh.Name = "Mesh"
BaseLaserMesh.MeshType = Enum.MeshType.FileMesh
BaseLaserMesh.MeshId = (BaseUrl .. "9856898")
BaseLaserMesh.TextureId = (BaseUrl .. "1361097")
BaseLaserMesh.Scale = Vector3.new(0.4, (BaseLaser.Size.Y * 2), 0.4) --Default mesh scale is 1/2 the size of a 1x1x1 brick.
BaseLaserMesh.Offset = Vector3.new(0, 0, 0)
BaseLaserMesh.VertexColor = Vector3.new(1, 1, 1)
BaseLaserMesh.Parent = BaseLaser

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

R15GripRight = Vector3.new(0.615, 0, -0.788)

Rate = (1 / 60)

FiringOffset = Vector3.new(0, 0.3, -1.25)

ToolEquipped = false
Reloading = false
MouseDown = false

Configuration = {
	Accuracy = Vector3.new(0.1, 0.1, 0.1),
	Damage = {Min = 15, Max = 20},
	FireRate = 0.75,
	Range = 75,
	Burst = {
		Bullets = {Min = 0, Max = 0},
		Offset = Vector3.new(1, 1, 1),
	},
	Display = {
		FadeRate = 1,
		LaserColor = BrickColor.new("Pastel Blue").Color
	}
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function LaserTouched(Hit, Position)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	local DeterminedDamage = math.random(Configuration.Damage.Min, Configuration.Damage.Max)
	local HealthAfter = (humanoid.Health - DeterminedDamage)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DeterminedDamage)
	if HealthAfter <= 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				v:Destroy()
			end
		end
	end
end

function FireLaser(StartPosition, TargetPosition)
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	local TotalDistance = 0
	local RayHit, RayPos, RayNormal = Functions.CastRay(StartPosition, Direction, Configuration.Range, {Character}, false)
	local Vec = (StartPosition - RayPos)
	local RayLength = Vec.magnitude
	TotalDistance = (TotalDistance + RayLength)
	local NewCFrame = CFrame.new(StartPosition, (StartPosition + Vec))
	local Laser = BaseLaser:Clone()
	local LaserMesh = Laser.Mesh
	Laser.Transparency = 0.5
	local LaserColor = ((not Player.Neutral and Player.TeamColor) or Configuration.Display.LaserColor)
	LaserMesh.VertexColor = Vector3.new(LaserColor.r, LaserColor.g, LaserColor.b)
	LaserMesh.Scale = Vector3.new(LaserMesh.Scale.X, (RayLength * 2), LaserMesh.Scale.Z)
	local FadeDuration = Configuration.Display.FadeRate
	local FadeRate = 10
	if FadeDuration > 0 then
		Spawn(function()
			for i = 1, ((1 - Laser.Transparency) * (1 * FadeRate)) do
				Laser.Transparency = (Laser.Transparency + (1 / FadeRate))
				wait(Rate)
			end
		end)
	end
	Debris:AddItem(Laser, FadeDuration)
	Laser.Transparency = 1
	Laser.Parent = game:GetService("Workspace")
	Laser.CFrame = (NewCFrame * CFrame.new(0, 0, (RayLength / 2)) * CFrame.Angles((math.pi / 2), 0, 0))
	local DisplayPart = BasePart:Clone()
	local Particles = Beam:Clone()
	Particles.Enabled = true
	Particles.Parent = DisplayPart
	DisplayPart.Name = "Effect"
	DisplayPart.Transparency = 1
	DisplayPart.Size = Vector3.new(BaseLaser.Size.X, RayLength, BaseLaser.Size.Z)
	DisplayPart.CFrame = Laser.CFrame
	DisplayPart.Anchored = true
	DisplayPart.CanCollide = false
	DisplayPart.Parent = Laser
	LaserTouched(RayHit, RayPos)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or Reloading then
		return
	end
	Tool.Enabled = false
	local BurstAmount = math.random(Configuration.Burst.Bullets.Min, Configuration.Burst.Bullets.Max)
	local WithinFiringRange = false
	local FireSound = Sounds.Fire:Clone()
	Debris:AddItem(FireSound, 1.25)
	FireSound.Parent = Handle
	FireSound:Play()
	for i = 1, ((BurstAmount > 0 and BurstAmount) or 1) do
		local StartPosition = (Handle.CFrame * CFrame.new(FiringOffset.X, FiringOffset.Y, FiringOffset.Z)).p
		local TargetPosition = InvokeClient("MousePosition")
		if not TargetPosition then
			Tool.Enabled = true
			return
		end
		TargetPosition = TargetPosition.Position
		if BurstAmount > 0 then
			local Offset = (Configuration.Burst.Offset * 100)
			TargetPosition = TargetPosition + Vector3.new((math.random(-Offset.X, Offset.X) * 0.01), (math.random(-Offset.Y, Offset.Y) * 0.01), (math.random(-Offset.Z, Offset.Z) * 0.01))
		end
		local Accuracy = (Configuration.Accuracy * 100)
		TargetPosition = TargetPosition + Vector3.new((math.random(-Accuracy.X, Accuracy.X) * 0.01), (math.random(-Accuracy.Y, Accuracy.Y) * 0.01), (math.random(-Accuracy.Z, Accuracy.Z) * 0.01))
		FireLaser(StartPosition, TargetPosition)
	end
	wait(Configuration.FireRate)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Tool.GripRight = R15GripRight
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			Tool.GripRight = Vector3.new(1, 0, 0)
		end
	end
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
				InvokeClient("PlayAnimation", Animations.Hold)
			elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", Animations.R15Hold)				
			end
		end
	end)
	local limbs = {"Left Arm", "Right Arm"}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		limbs = {"RightUpperArm", "RightLowerArm", "RightHand", "LeftHand", "LeftLowerArm", "LeftUpperArm"}
	end
	for i, v in pairs(limbs) do
		local Arm = Character:FindFirstChild(v)
		if Arm then
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
			end)
		end
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	MouseDown = false
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)