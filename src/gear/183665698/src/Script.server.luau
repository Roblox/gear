--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ViolinSong = Handle:WaitForChild("ViolinSong")

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

Grips = {
	Equipped = CFrame.new(-1.25, -1, 0.100000001, -0.823578298, -0.031555742, 0.566324174, -0.453762144, -0.5624156, -0.691222489, 0.34032163, -0.826252341, 0.448874444),
	Default = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Meshes = {
	ViolinWithBow = "http://www.roblox.com/asset?id=183439731",
	Violin = "http://www.roblox.com/asset?id=181327153",
	Bow = "http://www.roblox.com/asset?id=181327174"
}

Animations = {
	BowEquip = {Animation = Tool:WaitForChild("BowEquip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 2},
	StartPlaying = {Animation = Tool:WaitForChild("StartPlaying"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1},
	Playing = {Animation = Tool:WaitForChild("Playing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
}

StrikeDamage = 15
Duration = 60 --Song is 54 seconds long
ReloadTime = 60

LaunchDistance = 200
PossibleIncomingVectors = {}

Bow = BasePart:Clone()
Bow.Name = "ViolinBow"
Bow.Size = Vector3.new(0.25, 4.5, 0.5)
BowMesh = Instance.new("SpecialMesh")
BowMesh.MeshType = Enum.MeshType.FileMesh
BowMesh.MeshId = Meshes.Bow
BowMesh.TextureId = Mesh.TextureId
BowMesh.Scale = Mesh.Scale
BowMesh.Parent = Bow

OrbitalViolinModel = Instance.new("Model")
OrbitalViolinModel.Name = "OrbitalViolin"
OrbitalViolin = BasePart:Clone()
OrbitalViolin.Name = "Violin"
OrbitalViolin.Size = Vector3.new(2, 4.75, 1)
ViolinMesh = Instance.new("SpecialMesh")
ViolinMesh.MeshType = Enum.MeshType.FileMesh
ViolinMesh.MeshId = Meshes.Violin
ViolinMesh.TextureId = Mesh.TextureId
ViolinMesh.Scale = Vector3.new(1, 1, 1)
ViolinMesh.Parent = OrbitalViolin
OrbitalViolin.Parent = OrbitalViolinModel
OrbitalBow = BasePart:Clone()
OrbitalBow.Name = "Bow"
OrbitalBow.Size = Vector3.new(2, 4.75, 1)
BowMesh = Instance.new("SpecialMesh")
BowMesh.MeshType = Enum.MeshType.FileMesh
BowMesh.MeshId = Meshes.Bow
BowMesh.TextureId = Mesh.TextureId
BowMesh.Scale = Vector3.new(1, 1, 1)
BowMesh.Parent = OrbitalBow
OrbitalBow.Parent = OrbitalViolinModel
OrbitalViolinWeld = Instance.new("Weld")
OrbitalViolinWeld.Part0 = OrbitalViolin
OrbitalViolinWeld.Part1 = OrbitalBow
OrbitalViolinWeld.C0 = CFrame.new(0.5, -0.5, -0.5) * CFrame.Angles(0, math.pi, (math.pi / 2.75))
OrbitalViolinWeld.Parent = OrbitalViolin

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Mesh.MeshId = Meshes.Violin
Tool.Grip = Grips.Default
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
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

-- Create table of possible incoming vectors
for x = -1, 1 do
	for z = -1, 1 do
		table.insert(PossibleIncomingVectors, Vector3.new(x, 1, z).unit)
	end
end

function GetRandomFloat(Minimum, Maximum)
	local UnitRandom = math.random()
	local Interval = (Maximum - Minimum)
	-- there is potential overflow here if the interval is larger than max float
	if Interval <= 0 then
		return --The range beween minimum and maximum is less than zero.
	end
	return ((UnitRandom * Interval) + Minimum)
end

function RandomPointInCircle(MinRadius, MaxRadius)
	local OutwardVector = Vector3.new(0, 0, GetRandomFloat(MinRadius, MaxRadius))
	local Rotation = (math.random() * math.pi * 2)
	return CFrame.Angles(0, Rotation, 0) * OutwardVector	
end

function CheckTable(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function RayIgnoreCheck(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local IgnoreNames = {"Water", "Effect", "Rocket", "Bullet", "Handle", "Projectile", "Arrow"}
	if Hit.Transparency >= 1 or CheckTable(IgnoreNames, Hit.Name) then
		return true
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(StartPos, Vector, RayLength)
	local HitObject, HitPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new((StartPos + (Vector * 0.01)), (Vector * RayLength)), {Character})
	if HitObject and HitPos then
		local Distance = (RayLength - (HitPos - StartPos).magnitude)
		if RayIgnoreCheck(HitObject) and Distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(HitPos, Vector, Distance)
		end
	end
	return HitObject, HitPos
end

function FindOptimalLaunchVector(Destination)
	local BestDistance = 0
	local BestVector = Vector3.new(0, 1, 0)
	local BestPosition = (Destination + BestVector)
	for i, v in pairs(PossibleIncomingVectors) do
		local HitObject, HitPos = RayCast(Destination, v, LaunchDistance)
		if (HitPos - Destination).magnitude > BestDistance then
			BestVector = v
			BestDistance = (HitPos - Destination).magnitude
			BestPosition = HitPos
		end
	end
	return BestVector, BestPosition, BestDistance
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	ViolinBow = Bow:Clone()
	local Weld = Instance.new("Weld")
	Weld.Part0 = Torso
	Weld.Part1 = ViolinBow
	Weld.C0 = CFrame.new(1.05, -1, 1) * CFrame.Angles((math.pi / 2),0,0)
	Weld.Parent = ViolinBow
	ViolinBow.Parent = Tool
	local BowEquip = Animations.BowEquip
	InvokeClient("PlayAnimation", BowEquip)
	wait(BowEquip.Duration / 2)
	if not CurrentlyEquipped then
		return
	end
	Weld.Part0 = LeftArm
	Weld.C0 = CFrame.new(0, -1, -2) * CFrame.Angles(-(math.pi / 2), 0, 0)
	Weld.C0 = Weld.C0 * CFrame.Angles(0, -(math.pi / 4), 0)
	wait(BowEquip.Duration / 2)
	if not CurrentlyEquipped then
		return
	end
	Tool.Grip = Grips.Equipped
	local StartPlaying = Animations.StartPlaying
	InvokeClient("PlayAnimation", StartPlaying)
	wait(StartPlaying.Duration)
	if not CurrentlyEquipped then
		return
	end
	local Playing = Animations.Playing
	InvokeClient("PlayAnimation", Playing)
	ViolinSong:Play()
	local StartTime = tick()
	local Creator = Player
	local CreatorCharacter = Character
	while (tick() - StartTime) < Duration and CurrentlyEquipped do
		local ViolinOffset = RandomPointInCircle(20, 100)
		local MeteorViolinModel = OrbitalViolinModel:Clone()
		local MeteorViolin = MeteorViolinModel.Violin
		local MeteorBow = MeteorViolinModel.Bow
		local MeteorFire = Instance.new("Fire")
		MeteorFire.Heat = 20
		MeteorFire.Size = 18
		MeteorFire.Parent = MeteorViolin
		MeteorViolinModel.Parent = game:GetService("Workspace")
		local TargetPoint = Instance.new("Part")
		TargetPoint.Transparency = 1
		TargetPoint.CanCollide = false
		TargetPoint.Anchored = true
		TargetPoint.CFrame = CFrame.new(ViolinOffset) + Torso.CFrame.p
		Debris:AddItem(TargetPoint, 30)
		Debris:AddItem(MeteorViolinModel, 30)
		local ViolinPropulsion = Instance.new("RocketPropulsion")
		ViolinPropulsion.Target = TargetPoint
		ViolinPropulsion.MaxThrust = 100000
		ViolinPropulsion.MaxSpeed = 40
		ViolinPropulsion.Parent = MeteorViolin
		local MeteorHit = false
		for i, v in pairs(MeteorViolinModel:GetChildren()) do
			if v:IsA("BasePart") then
				v.Touched:connect(function(Hit)
					if Hit == MeteorViolin or Hit == MeteorBow or MeteorHit then
						return
					end
					local Explosion = Instance.new("Explosion")
					Explosion.BlastPressure = 0
					Explosion.BlastRadius = 15
					Explosion.Position = MeteorViolin.CFrame.p
					Explosion.Hit:connect(function(Hit2)
						if not Hit2 or not Hit2.Parent then
							return
						end
						local character = Hit2.Parent
						if character == CreatorCharacter then
							return
						end
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Creator)
							humanoid:TakeDamage(StrikeDamage)
						end
					end)
					Explosion.Parent = MeteorViolinModel
					for ii, vv in pairs(MeteorViolinModel:GetChildren()) do
						if vv:IsA("BasePart") then
							vv.Anchored = true
							vv.Transparency = 1
						end
					end
					if MeteorFire and MeteorFire.Parent then
						MeteorFire.Enabled = false
					end
					Debris:AddItem(MeteorViolinModel, 2)
				end)
			end
		end
		local BestVector, BestPosition, BestDistance = FindOptimalLaunchVector(TargetPoint.CFrame.p)
		TargetPoint.Parent = MeteorViolinModel
		MeteorViolin.CFrame = CFrame.new(BestPosition)
		ViolinPropulsion:Fire()
		wait(2)
	end
	ViolinSong:Stop()
	InvokeClient("StopAnimation", Playing)
	Tool.Grip = Grips.Default
	if ViolinBow and ViolinBow.Parent then
		ViolinBow:Destroy()
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Mesh.MeshId = Meshes.Violin
end

function Unequipped()
	Mesh.MeshId = Meshes.ViolinWithBow
	Tool.Grip = Grips.Default
	ViolinSong:Stop()
	if ViolinBow and ViolinBow.Parent then
		ViolinBow:Destroy()
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)