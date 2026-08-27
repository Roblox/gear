--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Model:WaitForChild("Creator").Value
PlayBack = Model:WaitForChild("PlayBack").Value
Duration = Model:WaitForChild("Duration").Value
Position = Model:WaitForChild("Position").Value
Count = Model:WaitForChild("Count").Value

Music = script:WaitForChild("Music")

BaseUrl = "http://www.roblox.com/asset/?id="

Radius = {
	Min = 0.2,
	Max = 20,
	Rate = 0.2
}

Gravity = 196.20

Rate = (1 / 60)

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

Piano = BasePart:Clone()
Piano.Name = "Piano"
Piano.Size = Vector3.new(5.5, 6.5, 6.25)
Piano.Friction = 2
Piano.Elasticity = 0
PianoMesh = Instance.new("SpecialMesh")
PianoMesh.MeshType = Enum.MeshType.FileMesh
PianoMesh.MeshId = (BaseUrl .. "233083187")
PianoMesh.TextureId = (BaseUrl .. "233083246")
PianoMesh.Scale = Vector3.new(1, 1, 1)
PianoMesh.VertexColor = Vector3.new(1, 1, 1)
PianoMesh.Offset = Vector3.new(0, 0, 0)
PianoMesh.Parent = Piano
PianoSound = Music:Clone()
PianoSound.Parent = Piano

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

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function CreateEffect(Position)
	local Beam = BasePart:Clone()
	Beam.Name = "Beam"
	Beam.BrickColor = BrickColor.new("New Yeller")
	Beam.Material = Enum.Material.Plastic
	Beam.Reflectance = 0.5
	Beam.Transparency = 0.75
	Beam.Size = Vector3.new(1, 1, 1)
	Beam.CanCollide = false
	Beam.Anchored = true
	local BeamMesh = Instance.new("CylinderMesh")
	BeamMesh.Scale = Vector3.new(Radius.Min, 1000, Radius.Min)
	BeamMesh.Parent = Beam
	Beam.Parent = Model
	Beam.CFrame = (Position * CFrame.new(0, (0 + (BeamMesh.Scale.Y / 2)), 0))
	--[[local LaserBeam = Beam:Clone()
	LaserBeam.Name = "LaserBeam"
	LaserBeam.Transparency = 0.25
	LaserBeam.Reflectance = 0.1
	LaserBeam.BrickColor = BrickColor.new("Really red")
	LaserBeam.Mesh.Scale = Vector3.new(0.2, LaserBeam.Mesh.Scale.Y, 0.2)
	LaserBeam.CFrame = Beam.CFrame]]
	for i = 1, (Radius.Max / Radius.Rate) do
		local Scale = (Radius.Min * i)
		BeamMesh.Scale = Vector3.new(Scale, BeamMesh.Scale.Y, Scale)
		wait(Rate)
	end
	local SpawnLocation = (Beam.CFrame * CFrame.new(0, -(BeamMesh.Scale.Y / 4), 0))
	local DisplayPiano = Piano:Clone()
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.Parent = DisplayPiano
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(0, (Piano:GetMass() * Gravity), 0)
	BodyVelocity.velocity = Vector3.new(0, -150, 0)
	BodyVelocity.Parent = DisplayPiano
	DisplayPiano.CFrame = SpawnLocation
	DisplayPiano.CFrame = DisplayPiano.CFrame
	BodyGyro.cframe = DisplayPiano.CFrame
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.maxForce = Vector3.new(math.huge, 0, math.huge)
	BodyPosition.position = DisplayPiano.CFrame.p
	BodyPosition.Parent = DisplayPiano
	Debris:AddItem(DisplayPiano, 60)
	DisplayPiano.Parent = Model
	while DisplayPiano and DisplayPiano.Parent do
		local RayHit, RayPos, RayNormal = RayCast(DisplayPiano.Position, Vector3.new(0, -1, 0), ((DisplayPiano.Size.Y / 2) + 0.25), {Beam})
		if RayHit and DisplayPiano.Velocity.magnitude < 5 then
			break
		end
		wait(Rate)
	end
	local PianoCFrame = DisplayPiano.CFrame
	local Seat = Instance.new("Seat")
	Seat.Name = "Seat"
	Seat.Material = Enum.Material.Plastic
	Seat.Shape = Enum.PartType.Block
	Seat.TopSurface = Enum.SurfaceType.Smooth
	Seat.BottomSurface = Enum.SurfaceType.Smooth
	Seat.FormFactor = Enum.FormFactor.Custom
	Seat.Size = Vector3.new(0.2, 0.2, 0.2)
	Seat.Locked = true
	Seat.CanCollide = true
	Seat.Anchored = false
	Seat.Size = Vector3.new(5, 1.125, 1.75)
	local SeatMesh = Instance.new("SpecialMesh")
	SeatMesh.MeshType = Enum.MeshType.FileMesh
	SeatMesh.MeshId = (BaseUrl .. "111868131")
	SeatMesh.TextureId = (BaseUrl .. "111867655")
	SeatMesh.Scale = Vector3.new(1, 0.5, 0.5)
	SeatMesh.Parent = Seat
	Seat.CFrame = DisplayPiano.CFrame * CFrame.new(0.365, -2.65, 4.25) * CFrame.Angles(0, (math.pi / 40), 0)
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Seat.CFrame
	BodyGyro.Parent = Seat
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.maxForce = Vector3.new(math.huge, 0, math.huge)
	BodyPosition.position = Seat.CFrame.p
	BodyPosition.Parent = Seat
	Seat.Parent = Model
	local CreatorCharacter = Creator.Character
	if CreatorCharacter and CreatorCharacter.Parent then
		local CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
		if CreatorTorso then
			local SeatWeld = Instance.new("Weld")
			SeatWeld.Name = "SeatWeld"
			SeatWeld.Part0 = Seat
			SeatWeld.Part1 = CreatorTorso
			SeatWeld.C0 = CFrame.new(0, (Seat.Size.Y / 2), 0)
			SeatWeld.C1 = CFrame.new(0, -1.5, 0)
			SeatWeld.Parent = Seat
		end
	end
	wait(2)
	--LaserBeam.Parent = Model
	Spawn(function()
		local Radius = Vector3.new(2000, 1000, 2000)
		local SpawnRate = ((Duration / Count) / 2)
		for i = 1, (Count * 2) do
			for ii = 1, math.random(1, 3) do
				local KillerPiano = Piano:Clone()
				KillerPiano.CFrame = SpawnLocation * CFrame.new((math.random(-Radius.X, Radius.X) * 0.01), (math.random(-Radius.Y, Radius.Y) * 0.01), (math.random(-Radius.Z, Radius.Z) * 0.01)) * CFrame.Angles((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01))
				local BodyPosition = Instance.new("BodyPosition")
				BodyPosition.maxForce = Vector3.new(math.huge, 0, math.huge)
				BodyPosition.position = KillerPiano.CFrame.p
				BodyPosition.Parent = KillerPiano
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.maxForce = Vector3.new(0, (Piano:GetMass() * Gravity), 0)
				BodyVelocity.velocity = Vector3.new(0, -500, 0)
				BodyVelocity.Parent = DisplayPiano
				local Fire = Instance.new("Fire")
				Fire.Color = Color3.new((236 / 255), (139 / 255), (70 / 255))
				Fire.SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255))
				Fire.Heat = 10
				Fire.Size = 12.5
				Fire.Enabled = true
				Fire.Parent = KillerPiano
				Debris:AddItem(KillerPiano, 15)
				KillerPiano.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent or KillerPiano.Velocity.magnitude < 5 then
						return
					end
					local character = Hit.Parent
					if character:IsA("Hat") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local player = Players:GetPlayerFromCharacter(character)
					if player and (player == Creator or IsTeamMate(Creator, player)) then
						return
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Creator)
					humanoid:TakeDamage(15)
				end)
				KillerPiano.Parent = Model
			end
			wait(SpawnRate)
		end
	end)
	Music = DisplayPiano.Music
	for i = 1, 2 do
		if Disabled then
			break
		end
		Music:Stop()
		Music:Play()
		wait(23.849)--Music.TimeLength)
	end
	Music:Stop()
	wait(0.25)
	--[[if LaserBeam and LaserBeam.Parent then
		LaserBeam:Destroy()
	end]]
	for i = 1, ((Radius.Max) / Radius.Rate) do
		local Scale = (Radius.Max - (Radius.Min * i))
		BeamMesh.Scale = Vector3.new(Scale, BeamMesh.Scale.Y, Scale)
		wait(Rate)
	end
	if Beam and Beam.Parent then
		Beam:Destroy()
	end
end

function DestroyModel()
	Disabled = true
	Music:Stop()
	Debris:AddItem(Model, 2)
end

if not Creator or not Creator:IsA("Player") or not Creator.Parent then
	DestroyModel()
	return
end

Character = Creator.Character
if not Character then
	DestroyModel()
	return
end

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator.Parent then
		DestroyModel()
	end
end)

Character.Changed:connect(function(Property)
	if Property == "Parent" and not Character.Parent then
		DestroyModel()
	end
end)

CreateEffect(Position)

Music:Stop()
Model:Destroy()