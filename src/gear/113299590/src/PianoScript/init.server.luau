--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Meshes = {
	Chair = script:WaitForChild("ChairMesh"),
	Piano = script:WaitForChild("PianoMesh")
}

Grips = {
	Display = CFrame.new(-1.25, 1.75, -3.25, -1, 0, -8.74227766e-008, 0, 1, 0, 8.74227766e-008, 0, -1),
	Equipped = CFrame.new(0, 0, -1, -1, 0, 0, 0, 1, 0, 0, 0, -1)
}

Scales = {
	Display = Vector3.new(2, 2, 2),
	Equipped = Vector3.new(0.4, 0.4, 0.4)
}

Music = script:WaitForChild("Music")
MeteorPianoScript = script:WaitForChild("MeteorPianoScript")

CoolDownTime = 35
LaunchDistance = 200

LastActivation = 0

NumberOfMeteors = 14

PossibleIncomingVectors = {}

Chair = Instance.new("Seat")
Chair.Name = "Chair"
Chair.Locked = true
Chair.Material = Enum.Material.Plastic
Chair.Shape = Enum.PartType.Block
Chair.TopSurface = Enum.SurfaceType.Smooth
Chair.BottomSurface = Enum.SurfaceType.Smooth
Chair.FormFactor = Enum.FormFactor.Custom
Chair.Size = Vector3.new(2, 1.65, 2)
ChairMesh = Meshes.Chair:Clone()
ChairMesh.Parent = Chair
ChairGyro = Instance.new("BodyGyro")
ChairGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
ChairGyro.Parent = Chair

Piano = Instance.new("Part")
Piano.Name = "Piano"
Piano.Locked = true
Piano.Material = Enum.Material.Plastic
Piano.Shape = Enum.PartType.Block
Piano.TopSurface = Enum.SurfaceType.Smooth
Piano.BottomSurface = Enum.SurfaceType.Smooth
Piano.FormFactor = Enum.FormFactor.Custom
Piano.Size = Vector3.new(4.8, 4.125, 6)
PianoMesh = Meshes.Piano:Clone()
PianoMesh.Parent = Piano
PianoMusic = Music:Clone()
PianoMusic.Parent = Piano

Tool.Grip = Grips.Equipped
Mesh.Scale = Scales.Equipped

Tool.Enabled = true

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

function DismountSeat()
	for i, v in pairs({FigureChanged, HumanoidSeated, HumanoidDied, SeatWeldChanged}) do
		if v then
			v:disconnect()
		end
	end
	if SeatWeld and SeatWeld.Parent then
		SeatWeld:Destroy()
	end
end

function Activated()
	if (tick() - LastActivation) > CoolDownTime then
		Tool.Enabled = false
		LastActivation = tick()
		Handle.Transparency = 1
		Delay((CoolDownTime - 1), function()
			Handle.Transparency = 0
			Tool.Enabled = true
		end)
		if Torso then
			local Offset = Torso.CFrame.lookVector * 4
			local NewChair = Chair:Clone()
			local NewPiano = Piano:Clone()
			local PianoGyro = Instance.new("BodyGyro")
			PianoGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			PianoGyro.Parent = NewPiano
			local Fire = Instance.new("Fire")
			Fire.Enabled = false
			Fire.Heat = 14
			Fire.Parent = NewPiano
			NewChair.Parent = game:GetService("Workspace")
			NewPiano.Parent = game:GetService("Workspace")
			Debris:AddItem(NewChair, (CoolDownTime - 1))
			Debris:AddItem(NewPiano, (CoolDownTime - 1))
			local ChairCFrame = CFrame.new(Torso.CFrame.p, (Torso.CFrame.p + Offset))
			local PianoCFrame = CFrame.new((Torso.CFrame.p + Offset), Torso.CFrame.p)
			NewChair.CFrame = ChairCFrame - ChairCFrame.lookVector * (Chair.Size.Z / 2)
			NewChair.BodyGyro.cframe = ChairCFrame
			NewPiano.CFrame = PianoCFrame
			PianoGyro.cframe = PianoCFrame
			SeatWeld = Instance.new("Weld")
			SeatWeld.Name = "SeatWeld"
			SeatWeld.Part0 = NewChair
			SeatWeld.Part1 = Torso
			SeatWeld.C0 = CFrame.new(0, (Chair.Size.Y / 2), 0)
			SeatWeld.C1 = CFrame.new(0, -1.5, 0)
			SeatWeld.Parent = NewChair
			local EndMeteors = false
			CharacterChanged = Character.Changed:connect(function(Property)
				if Property == "Property" and not Character.Parent then
					DismountSeat()
				end
			end)
			HumanoidSeated = Humanoid.Seated:connect(function(Boolean)
				if not Boolean then
					DismountSeat()
				end
			end)
			HumanoidDied = Humanoid.Died:connect(function()
				DismountSeat()
			end)
			SeatWeldChanged = SeatWeld.Changed:connect(function(Property)
				if Property == "Parent" and SeatWeld.Parent ~= NewChair then
					DismountSeat()
					EndMeteors = true
				end
			end)
			wait(2)
			local NewPianoMusic = NewPiano:FindFirstChild("Music")
			if NewPianoMusic then
				NewPianoMusic:Play()
			end
			local MeteorCount = 0
			for i = 1, NumberOfMeteors do
				if NewChair:FindFirstChild("SeatWeld") then
					Fire.Enabled = true
					Fire.Size = (3 + i)
					if EndMeteors then
						MeteorCount = NumberOfMeteors
					else
						MeteorCount = (MeteorCount + 1)
					end
					local PianoOffset = RandomPointInCircle(20, 100)
					if i == NumberOfMeteors then -- hard-code last one to Hit you
						PianoOffset = Vector3.new()
					end
					local MeteorPiano = Piano:Clone()
					local MeteorFire = Instance.new("Fire")
					local NewScript = MeteorPianoScript:Clone()
					MeteorFire.Heat = 20
					MeteorFire.Size = 18
					MeteorFire.Parent = MeteorPiano
					MeteorPiano.Parent = game:GetService("Workspace")
					local TargetPoint = Instance.new("Part")
					TargetPoint.Transparency = 1
					TargetPoint.CanCollide = false
					TargetPoint.Anchored = true
					TargetPoint.CFrame = CFrame.new(PianoOffset) + Torso.CFrame.p
					Debris:AddItem(TargetPoint, 30)
					Debris:AddItem(MeteorPiano, 30)
					local PianoPropulsion = Instance.new("RocketPropulsion")
					PianoPropulsion.Target = TargetPoint
					PianoPropulsion.MaxThrust = 100000
					PianoPropulsion.MaxSpeed = 40
					PianoPropulsion.Parent = MeteorPiano
					TargetPoint.Parent = game:GetService("Workspace")
					local BestVector, BestPosition, BestDistance = FindOptimalLaunchVector(TargetPoint.CFrame.p)
					MeteorPiano.CFrame = CFrame.new(BestPosition)
					PianoPropulsion:Fire()
					NewScript.Parent = MeteorPiano
					NewScript.Disabled = false
				else
					if NewPianoMusic then
						NewPianoMusic:Stop()
					end
					for i, v in pairs({NewPiano, NewChair}) do
						if v and v.Parent then
							v:Destroy()
						end
					end
					return
				end
				wait(2)
			end
			wait(3)
			for i, v in pairs({NewPiano, NewChair}) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
				Humanoid.Sit = false
				Humanoid.Jump = true
			end
		end
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end
	
function Unequipped()
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Activated:connect(Activated)
Tool.Unequipped:connect(Unequipped)