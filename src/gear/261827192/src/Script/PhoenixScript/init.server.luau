--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Phoenix = script.Parent
Body = Phoenix:WaitForChild("Torso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://wwww.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseFireBall = BasePart:Clone()
BaseFireBall.Name = "Projectile"
BaseFireBall.Transparency = 0
BaseFireBall.Shape = Enum.PartType.Ball
BaseFireBall.Size = Vector3.new(1, 1, 1)
BaseFireBall.CanCollide = false
FireBallMesh = Create("SpecialMesh"){
	MeshId = (BaseUrl .. "57810032"),
	TextureId = (BaseUrl .. "57809568"),
	Scale = Vector3.new(2, 2, 2),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseFireBall,
}

Objects = {
	Creator = Phoenix:WaitForChild("Creator"),
	Tool = Phoenix:WaitForChild("Tool"),
	TargetPoint = Phoenix:WaitForChild("TargetPoint"),
	LeftWing = Body:WaitForChild("LeftWing"),
	RightWing = Body:WaitForChild("RightWing"),
	LeftWingWeld = Body:WaitForChild("LeftWingWeld"),
	RightWingWeld = Body:WaitForChild("RightWingWeld"),
	Fire = Body:WaitForChild("Fire"),
	Sound = Body:WaitForChild("Sound"),
}

Settings = {
	Aggressive = true, --Phoenix will attack enemies
	FriendlyFire = false, --Whether you can damage your teammates or not
	SmallDamage = 15,
	LargeDamage = 25, --Does more damage while tool is equipped
	AttackRange = 40,
	ShortReload = 2.5, --Shoots faster if given an Assigned area to move to
	LongReload = 4,
	EquipReloadBonus = -1.25, --Shoots faster when tool is equipped
	AssignmentDuration = 11,
	MaxSpeed = 80,
	Acceleration = 20,
	SubAcceleration = 4, --Relative speed when approaching target
	SearchRangeXZ = 35,
	SearchRangeY = 15,
	ChaseRange = 60,
}

Rate = (1 / 60)
Gravity = 196.20

LastAssignment = (tick() - 1000)
MoveToPoint = Vector3.new(0,0,0)
EnemyTarget = nil
Shooting = false

Fires = {Body:FindFirstChild("Fire"), Objects.LeftWing:FindFirstChild("Fire"), Objects.RightWing:FindFirstChild("Fire")}

Body.CanCollide = true

Objects.TargetPoint.Changed:connect(function() 
	LastAssignment = tick()
	MoveToPoint = Objects.TargetPoint.Value
end)

function GetCreator()
	local CreatorValue = Objects.Creator.Value
	return ((CreatorValue and CreatorValue.Parent and ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(CreatorValue))) or nil)
end

function CheckIfPhoenixAlive()
	return (((Phoenix and Phoenix.Parent and Body and Body.Parent) and true) or false)
end

function IsToolEquipped()
	local Creator = GetCreator()
	local Tool = Objects.Tool.Value
	if not Creator then
		return false
	end
	local Character = Creator.Character
	if not Character or not Character.Parent then
		return false
	end
	if not Tool or not Tool.Parent or Tool.Parent ~= Character then
		return false
	end
	return true
end

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or not humanoid:IsA("Humanoid") or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		local CreatorPlayer = GetCreator()
		if player and CreatorPlayer and (player == CreatorPlayer or (not Settings.FriendlyFire and Functions.IsTeamMate(CreatorPlayer, player))) then
			return
		end
		local creator = character:FindFirstChild("Creator")
		if creator and creator:IsA("ObjectValue") and creator.Value == CreatorPlayer then
			return
		end
		local DamageAmount = ((IsToolEquipped() and Settings.LargeDamage) or Settings.SmallDamage)
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, CreatorPlayer)
		humanoid:TakeDamage(DamageAmount)
	end)
	return TouchedConnection
end

function Shoot(Object)
	if not CheckIfPhoenixAlive() then
		return false
	end
	local BodyGyro = Body:FindFirstChild("BodyGyro")
	local StartPosition = (Body.Position + Vector3.new(0, 2, 0))
	local Direction = (Object.Position - Body.Position).Unit
	if BodyGyro then
		BodyGyro.cframe = CFrame.new(StartPosition, (StartPosition + Direction))
	end
	wait(0.5)
	if not CheckIfPhoenixAlive() or not Object or not Object.Parent then
		return false
	end
	StartPosition = (Body.Position + Vector3.new(0, 2, 0))
	Direction = (Object.Position - Body.Position).Unit
	Objects.Sound:Play()
	local SpawnPos = (StartPosition + Direction * 4)
	local FireBall = BaseFireBall:Clone()
	FireBall.CFrame = CFrame.new(SpawnPos, (SpawnPos + Direction))
	FireBall.Velocity = (Direction * 60)
	local Float = Create("BodyForce"){
		force = Vector3.new(0, (FireBall:GetMass() * Gravity), 0),
		Parent = FireBall,
	}
	local Fire = Objects.Fire:Clone()
	Fire.Parent = FireBall
	Debris:AddItem(FireBall, 5)
	FireBall.Parent = game:GetService("Workspace")
	Blow(FireBall)
	wait(0.3)
	Shooting = false
	local ReloadTime
	if (tick() - LastAssignment) < Settings.AssignmentDuration then
		ReloadTime = Settings.ShortReload
	else
		ReloadTime = Settings.LongReload
	end
	if IsToolEquipped() then
		ReloadTime = (ReloadTime + Settings.EquipReloadBonus)
	end
	wait(ReloadTime - 0.8)
	return true
end

function FlapWings()
	local Sign = 1
	local Count = 0
	if Objects.LeftWingWeld and Objects.RightWingWeld then 
		while CheckIfPhoenixAlive() and Objects.LeftWingWeld and Objects.RightWingWeld do		
			Objects.LeftWingWeld.C1 = (Objects.LeftWingWeld.C1 * CFrame.Angles(0, (-Sign * math.pi / 30), 0)) 
			Objects.RightWingWeld.C1 = (Objects.RightWingWeld.C1 * CFrame.Angles(0, (Sign * math.pi / 30), 0)) 
			Count = (Count + 1)
			if Count > 7 then 
				Sign = (Sign * -1)
				Count = (Count % 6)					
			end 
			wait(1 / 15)
		end 
	end 
end

function TweenColor(Object, Property, CurrentColor, DesiredColor, Time)
	local Difference = {
		Red = (DesiredColor.r - CurrentColor.r),
		Green = (DesiredColor.g - CurrentColor.g),
		Blue = (DesiredColor.b - CurrentColor.b),
	}
	local ChangeRate = 30
	for i = 1, (Time * ChangeRate) do
		local NewColor = Color3.new(
			(CurrentColor.r + Difference.Red / (Time * ChangeRate)),
			(CurrentColor.g + Difference.Green / (Time * ChangeRate)),
			(CurrentColor.b + Difference.Blue / (Time * ChangeRate))
		)
		CurrentColor = NewColor
		pcall(function()
			Object[Property] = NewColor
		end)
		wait(Rate)
	end
end 

function AdjustColor()
	local NewColor = Color3.new(math.random(), math.random(), math.random())
	for i, v in pairs(Fires) do
		Spawn(function()
			local Color = v.Color
			TweenColor(v, "Color", Color, NewColor, 1.5)
			TweenColor(v, "SecondaryColor", Color, NewColor, 1)
		end)
	end
end

function MoveToTarget()
	local MoveDelay = 0.3
	local CircleCounter = 0
	local BodyVelocity = Create("BodyVelocity"){
		velocity = Vector3.new(0,0,0),
		maxForce = Vector3.new(10000, 20000, 10000),
		Parent = Body,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(1500, 1500, 1500),
		Parent = Body,
	}
	local OwnerDead = false
	local function OwnerKilled()
		if OwnerDead then
			return
		end
		OwnerDead = true
		Debris:AddItem(Phoenix, 3.5)
		Delay(1.5, (function()
			Settings.Aggressive = false
			for i, v in pairs(Fires) do
				v.Size = 10
				v.Heat = 25
			end
		end))
	end
	while CheckIfPhoenixAlive() do
		Spawn(AdjustColor)
		local Creator = GetCreator()
		if not Creator or not Creator.Character or not Creator.Character.Parent then
			OwnerKilled()
		else
			local CreatorCharacter = Creator.Character
			local CreatorHumanoid = CreatorCharacter:FindFirstChild("Humanoid")
			if not CreatorHumanoid or not CreatorHumanoid:IsA("Humanoid") or CreatorHumanoid.Health == 0 then
				OwnerKilled()
			end
		end
		if not Shooting then
			if (tick() - LastAssignment) > Settings.AssignmentDuration and Creator and Creator.Character and Creator.Character.Parent then
				local CreatorCharacter = Creator.Character
				local torso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
				if torso then
					MoveToPoint = (torso.Position + Vector3.new(0, -2, 0))
				end
			end
			CircleCounter = (CircleCounter + 1)
			local AdjustedMovePoint = (MoveToPoint + CFrame.Angles(0, (CircleCounter / 7), 0) * Vector3.new(10, 6, 0)) 
			local MoveVector = (AdjustedMovePoint - Body.Position)
			local TargetSpeed = math.min(Settings.MaxSpeed, (Settings.SubAcceleration * math.sqrt(MoveVector.magnitude)))
			local CurrentMagnitude = BodyVelocity.velocity.Magnitude
			local NewSpeed
			if TargetSpeed > CurrentMagnitude then
				NewSpeed = math.min(TargetSpeed, (CurrentMagnitude + Settings.Acceleration * MoveDelay))
			else
				NewSpeed = math.max(TargetSpeed, (CurrentMagnitude - Settings.Acceleration * MoveDelay))
			end
			BodyVelocity.velocity = (MoveVector.Unit * NewSpeed)
			BodyGyro.cframe = CFrame.new(Body.Position, (Body.Position + MoveVector.Unit + Vector3.new(0, -3, 0)))
		end
		wait(MoveDelay)
	end
end

Spawn(FlapWings)
Spawn(MoveToTarget)

while CheckIfPhoenixAlive() do
	if Settings.Aggressive and (not EnemyTarget or (tick() - LastAssignment) < Settings.AssignmentDuration) then
		EnemyTarget = nil
		local PhoenixPos = (Body.Position + Vector3.new(0, -8, 0))
		local SearchVec = Vector3.new(Settings.SearchRangeXZ, Settings.SearchRangeY, Settings.SearchRangeXZ)
		local SearchRegion = Region3.new((PhoenixPos - SearchVec), (PhoenixPos + SearchVec))
		local Creator = GetCreator()
		local CreatorCharacter = ((Creator and Creator.Character) or nil)
		local PartsInRegion = Functions.GetParts(SearchRegion, 500, {Phoenix, CreatorCharacter})
		local ClosestPlayer = {Player = nil, Distance = Settings.ChaseRange}
		for i, v in pairs(PartsInRegion) do
			local PartDistance = (PhoenixPos - v.Position).Magnitude
			local character = v.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid:IsA("Humanoid") and humanoid.Health > 0 and PartDistance < ClosestPlayer.Distance then
				ClosestPlayer.Player = character
				ClosestPlayer.Distance = PartDistance
			end
		end
		if ClosestPlayer.Player then 
			EnemyTarget = ClosestPlayer.Player
		end
	end
	if Settings.Aggressive and EnemyTarget and GetCreator() then
		local humanoid = EnemyTarget:FindFirstChild("Humanoid")
		local torso = EnemyTarget:FindFirstChild("Torso") or EnemyTarget:FindFirstChild("UpperTorso")
		if not humanoid or not humanoid:IsA("Humanoid") or humanoid.Health == 0 or not torso then
			EnemyTarget = nil
		else
			while EnemyTarget and EnemyTarget.Parent and humanoid and humanoid.Health > 0 and torso and CheckIfPhoenixAlive() do
				local AttackDistance = (torso.Position - Body.Position).Magnitude
				if humanoid and humanoid.Health > 0 and AttackDistance < Settings.ChaseRange then
					Shooting = true
					local Success = Shoot(torso)
					Shooting = false
					if not Success then
						break
					end
				else
					EnemyTarget = nil
				end
				wait(Rate)
			end
			EnemyTarget = nil
		end
	end
	wait(2)
end