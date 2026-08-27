--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

PianoScript = script:WaitForChild("PianoScript")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

ValueNames = {"Creator", "Target", "Position"}
Values = {}

for i, v in pairs(ValueNames) do
	local Value = script:WaitForChild(v)
	Values[Value.Name] = Value.Value
end

Music = script:WaitForChild("Music")

Gravity = 196.20

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

Piano = BasePart:Clone()
Piano.Name = "Piano"
Piano.Size = Vector3.new(5.5, 5, 3.5)
Piano.Friction = 2
Piano.Elasticity = 0
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "332661198"),
	TextureId = (BaseUrl .. "332661035"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Piano,
}
Garland = Piano:Clone()
Garland.Name = "Garland"
Garland.Size = Vector3.new(5, 1, 1)
Garland.CanCollide = false
Garland.Mesh.MeshId = (BaseUrl .. "332661106")
GarlandMotor = Create("Motor6D"){
	Name = "Motor",
	Part0 = Piano,
	Part1 = Garland,
	C0 = (CFrame.new(0, 2.375, -0.25) * CFrame.Angles(0, (math.pi / 2), 0)),
	C1 = (CFrame.new(0, 0.75, 0.5) * CFrame.Angles(0, (math.pi / 2), 0)),
	CurrentAngle = 0,
	DesiredAngle = 0,
	MaxVelocity = 0.1,
	Parent = Garland,
}
Ornaments = Piano:Clone()
Ornaments.Name = "Ornaments"
Ornaments.Size = Vector3.new(1, 1, 1)
Ornaments.CanCollide = false
Ornaments.Mesh.MeshId = (BaseUrl .. "332661152")
OrnamentsMotor = Create("Motor6D"){
	Name = "Motor",
	Part0 = Piano,
	Part1 = Ornaments,
	C0 = (CFrame.new(-0.075, 2.75, 0.75) * CFrame.Angles(0, (math.pi / 2), 0)),
	C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
	CurrentAngle = 0,
	DesiredAngle = 0,
	MaxVelocity = 0.1,
	Parent = Ornaments,
}
Garland.Parent = Piano
Ornaments.Parent = Piano

PossibleMusic = {}
for i, v in pairs(Music:GetChildren()) do
	if v:IsA("Sound") then
		local Length = v:FindFirstChild("Length")
		if Length:IsA("NumberValue") and Length.Value > 0 then
			table.insert(PossibleMusic, v)
		end
	end
end

SelectedSound = PossibleMusic[math.random(1, #PossibleMusic)]:Clone()
SelectedSound.Name = "Music"
SelectedSound.Parent = Piano
PianoSound = SelectedSound:Clone()

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)) or Number)
end

function CreateEffect(Position)
	local SpawnLocation = (Position + Vector3.new(0, 250, 0))
	local DisplayPiano = Piano:Clone()
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		Parent = DisplayPiano,
	}
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(0, (Piano:GetMass() * Gravity), 0),
		velocity = Vector3.new(0, -150, 0),
		Parent = DisplayPiano,
	}
	DisplayPiano.CFrame = (SpawnLocation * CFrame.Angles(0, math.pi, 0))
	BodyGyro.cframe = DisplayPiano.CFrame
	local BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(math.huge, 0, math.huge),
		position = DisplayPiano.CFrame.p,
		Parent = DisplayPiano,
	}
	Debris:AddItem(DisplayPiano, 60)
	DisplayPiano.Parent = Model
	local ValueObjects = {
		{Name = "Creator", Class = "ObjectValue", Value = Values.Creator},
		{Name = "Model", Class = "ObjectValue", Value = Model},
		{Name = "Object", Class = "ObjectValue", Value = DisplayPiano},
		{Name = "Hit", Class = "BoolValue", Value = false},
		{Name = "Remove", Class = "BoolValue", Value = false},
	}
	local PianoScriptCopy = PianoScript:Clone()
	local DisableObject, HitObject, RemoveObject
	for i, v in pairs(ValueObjects) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = PianoScriptCopy,
		}
		if v.Name == "Object" then
			DisableObject = Value
		elseif v.Name == "Hit" then
			HitObject = Value
		elseif v.Name == "Remove" then
			RemoveObject = Value
		end
	end
	PianoScriptCopy.Disabled = false
	PianoScriptCopy.Parent = Values.Target
	Garland = DisplayPiano.Garland
	GarlandMotor = Garland.Motor
	Ornaments = DisplayPiano.Ornaments
	OrnamentsMotor = Ornaments.Motor
	RunService.Stepped:connect(function()
		local GarlandSpeed = {Min = 0, Max = 5}
		local Velocity = ((DisplayPiano.Velocity * Vector3.new(0, 1, 0)))
		local GarlandVelocity = (Clamp(GetPercentage(0, 100, Velocity.Magnitude), 0, 100) * 0.01)
		local RotationSpeed = Clamp((GarlandSpeed.Max * GarlandVelocity), GarlandSpeed.Min, GarlandSpeed.Max)
		local StartPoint = (DisplayPiano.CFrame + Vector3.new(0, 1, 0) * (DisplayPiano.Size.Y / 2))
		local EndPoint = (StartPoint + Velocity.Unit * Velocity.Magnitude)
		local MoveDirection = Clamp(((StartPoint.p - EndPoint.p).Unit + EndPoint.lookVector).Magnitude, 0, 2)
		local Direction = ((MoveDirection < 1 and 1) or -1)
		GarlandMotor.MaxVelocity = Clamp(math.abs(RotationSpeed * 0.01), 0.1, 1)
		OrnamentsMotor.MaxVelocity = Clamp(math.abs(RotationSpeed * 0.01), 0.1, 1)
		if math.floor(Velocity.Y) == 0 then
			GarlandMotor.DesiredAngle = 0
			OrnamentsMotor.DesiredAngle = 0
		else
			GarlandMotor.DesiredAngle = (2 * GarlandVelocity)
			OrnamentsMotor.DesiredAngle = (1 * GarlandVelocity * Direction)
		end
	end)
	local StartTick = tick()
	while DisplayPiano and DisplayPiano.Parent and (tick() - StartTick) < 10 do
		local RayHit, RayPos, RayNormal = RayCast(DisplayPiano.Position, Vector3.new(0, -1, 0), ((DisplayPiano.Size.Y / 2) + 0.25), {})
		if (RayHit and DisplayPiano.Velocity.Magnitude < 10) or RayHit and DisplayPiano.Velocity.Magnitude < 5 then
			break
		end
		wait(0.00001)
	end
	if DisplayPiano and DisplayPiano.Parent then
		local EnemyHead = Values.Target:FindFirstChild("Head")
		if EnemyHead and DisplayPiano.Position.Y > EnemyHead.Position.Y and (DisplayPiano.Position - EnemyHead.Position).Magnitude <= (DisplayPiano.Size.Y) then
			if HitObject then
				HitObject.Value = true
			end
			local PianoCFrame = DisplayPiano.CFrame
			local Seat = Create("Seat"){
				Name = "Seat",
				Material = Enum.Material.Plastic,
				Shape = Enum.PartType.Block,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				FormFactor = Enum.FormFactor.Custom,
				Size = Vector3.new(0.2, 0.2, 0.2),
				Locked = true,
				CanCollide = true,
				Anchored = false,
				Size = Vector3.new(5, 1.125, 1.75),
			}
			Create("SpecialMesh"){
				MeshType = Enum.MeshType.FileMesh,
				MeshId = (BaseUrl .. "111868131"),
				TextureId = (BaseUrl .. "111867655"),
				Scale = Vector3.new(1, 0.5, 0.5),
				Parent = Seat,
			}
			local SeatOffset = (CFrame.new(0, -2, -((Seat.Size.Z / 2) + (Piano.Size.Z / 2))) * CFrame.Angles(0, -math.pi, 0))
			Seat.CFrame = (DisplayPiano.CFrame * SeatOffset)
			local SeatWeld = Create("Weld"){
				Part0 = DisplayPiano,
				Part1 = Seat,
				C0 = SeatOffset,
				C1 = CFrame.new(0, 0, 0),
				Parent = Seat,
			}
			local BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				cframe = Seat.CFrame,
				Parent = Seat,
			}
			local BodyPosition = Create("BodyPosition"){
				maxForce = Vector3.new(math.huge, 0, math.huge),
				position = 	Seat.CFrame.p,
				Parent = Seat,
			}
			Seat.Parent = Model
			local CreatorCharacter = Values.Creator.Character
			if CreatorCharacter and CreatorCharacter.Parent then
				local CreatorHumanoid = CreatorCharacter:FindFirstChildOfClass("Humanoid")
				local CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
				if CreatorHumanoid and CreatorHumanoid.Health > 0 and CreatorTorso then
					local PlayingPiano = Create("BoolValue"){
						Name = "PlayingPiano",
						Value = true,
					}
					PianoSound = DisplayPiano.Music
					local TimeLength = PianoSound.Length.Value
					Debris:AddItem(PlayingPiano, (TimeLength + 3))
					PlayingPiano.Parent = CreatorCharacter
					local SeatWeld = Create("Weld"){
						Name = "SeatWeld",
						Part0 = Seat,
						Part1 = CreatorTorso,
						C0 = CFrame.new(0, (Seat.Size.Y / 2), 0),
						C1 = CFrame.new(0, -1.5, 0),
						Parent = Seat,
					}
					CreatorHumanoid.Sit = true
					SeatWeld.Changed:Connect(function(Property)
						if not SeatWeld.Parent or not SeatWeld.Part0 or not SeatWeld.Part1 then
							DestroyModel()
						end
					end)
					PianoSound:Play()
					local TimeToFade = 3
					local FadeRate = 0.05
					wait(TimeLength - TimeToFade)
					local OrigVolume = PianoSound.Volume
					for i = 1, (TimeToFade / FadeRate) do
						wait(FadeRate)
						PianoSound.Volume = (OrigVolume - (i / (TimeToFade / FadeRate)))
					end
					PianoSound:Stop()
					if DisableObject then
						DisableObject.Value = nil
					end
					wait(0.25)
				else
					RemoveObject.Value = true
				end
			else
				RemoveObject.Value = true
			end
		else
			RemoveObject.Value = true
		end
	else
		RemoveObject.Value = true
	end
end

function DestroyModel(Delay)
	PianoSound:Stop()
	wait(0.5) --Hacky way to ensure the sound has stopped...
	if Delay then
		Debris:AddItem(Model, 1)
	else
		Model:Destroy()
	end
end

if not Values.Creator or not Values.Creator:IsA("Player") or not Values.Creator.Parent then
	DestroyModel()
	return
end

Character = Values.Creator.Character
if not Character then
	DestroyModel()
	return
end

Values.Creator.Changed:Connect(function(Property)
	if Property == "Parent" and not Values.Creator.Parent then
		DestroyModel()
	end
end)

Character.Changed:Connect(function(Property)
	if Property == "Parent" and not Character.Parent then
		DestroyModel()
	end
end)

CreateEffect(Values.Position)

DestroyModel()