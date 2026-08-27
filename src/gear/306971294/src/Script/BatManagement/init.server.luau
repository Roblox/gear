--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Values = {}

Bats = {}
Scythes = {}

Rate = (1 / 60)

Removing = false

for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function DestroyModel()
	if Removing then
		return
	end
	Removing = true
	Model.Name = ""
	Debris:AddItem(Model, 0.5)
end

function RemoveModel()
	if Removing then
		return
	end
	local Objects = {}
	for i, v in pairs(Model:GetChildren()) do
		if v ~= script then
			table.insert(Objects, v)
		end
	end
	if #Objects == 0 then
		DestroyModel()
	end
end

function ChildAdded(Child)
	if Child:IsA("Model") and string.find(string.lower(Child.Name), string.lower("Bat")) then
		for i, v in pairs(Bats) do
			if v.Bat == Child then
				return
			end
		end
		local torso = Child:FindFirstChild("Torso")
		if not torso then
			return
		end
		local BodyGyro = torso:FindFirstChild("BodyGyro")
		local BodyPosition = torso:FindFirstChild("BodyPosition")
		if not BodyGyro or not BodyPosition then
			return
		end
		BatTouched(Child)
		table.insert(Bats, {Bat = Child, Torso = torso, BodyGyro = BodyGyro, BodyPosition = BodyPosition, Origin = {CFrame = nil, Nearby = false, Traveling = false}, TargetPoint = nil, SoundPlayedLast = tick()})
	elseif Child:IsA("BasePart") and Child.Name == "Scythe" then
		local ScytheTable = {Scythe = Child, StartPosition = Child.Position, Began = tick()}
		Child.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or Child.Name == "Effect" then
				return
			end
			FlyScythe(ScytheTable, Hit)
		end)
		table.insert(Scythes, ScytheTable)
	end
end

function ChildRemoved(Child)
	for i, v in pairs(Bats) do
		if v.Bat == Child then
			table.remove(Bats, i)
			break
		end
	end
end

function FlyScythe(Table, Hit)
	local Now = tick()
	if Table and Table.Scythe.Parent and (Now - Table.Began) > 0 then
		FlyProjectile(Table.Scythe, Hit, Table.StartPosition)
	end
end

function FlyProjectile(Part, Hit, StartPos)
	if Part.Name == "Effect" then
		return
	end
	local AlreadyHit = false
	local Player = Creator
	local function PartHit(Hit)
		if not Hit or not Hit.Parent or not Player or Part.Name == "Effect" then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Values.Damage.Value)
		return character
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.CFrame.lookVector, Length = (Part.Size.Z + 1)}, {Vector = Part.Velocity.Unit, Length = (Part.Size.Z + 1)}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = (Part.Size.Z + 1)}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = Functions.CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {((Player and Player.Character) or nil), Part}, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
		end
		return ((ClosestRay.Hit and ClosestRay) or nil)
	end
	local ClosestRay = CheckForContact(Hit)
	if ClosestRay then
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		if SuccessfullyHit then
		end
		Part.CanCollide = false
		local Hit = ClosestRay.Hit
		--[[local SoundPart = BasePart:Clone()
		SoundPart.Name = "Effect"
		SoundPart.Transparency = 1
		SoundPart.Anchored = true
		SoundPart.CanCollide = false
		local Sound = Sounds.Hit:Clone()
		Sound.Parent = SoundPart
		Debris:AddItem(SoundPart, 1.5)
		SoundPart.CFrame = Part.CFrame
		SoundPart.Parent = game:GetService("Workspace")
		Sound:Play()]]
		Part.Name = "Effect"
		local ProjectilePosition = ClosestRay.Pos
		local StickCFrame = ((StartPos and (CFrame.new(ProjectilePosition, StartPos) * CFrame.Angles((math.random(-600, 600) * 0.001), 0, 0))) or Part.CFrame)
		StickCFrame = (StickCFrame * CFrame.new(0, 0, (-(Part.Size.Z / 2) + 0)) * CFrame.Angles(0, math.pi, 0))
		local Weld = Create("Motor6D"){
			Part0 = ClosestRay.Hit,
			Part1 = Part,
			C0 = CFrame.new(0, 0, 0),
			C1 = (StickCFrame:inverse() * ClosestRay.Hit.CFrame),
			Parent = Part,
		}
	end
end

function PositionBats()
	for i, v in pairs(Bats) do
		if (not v.Origin.Nearby and not v.Traveling) or not v.Origin.CFrame then
			v.Origin.Traveling = true
			local RandomOffset = CFrame.new(math.random(Values.Range.Value.Origin.X, Values.Range.Value.Direction.X), math.random(Values.Range.Value.Origin.Y, Values.Range.Value.Direction.Y), math.random(Values.Range.Value.Origin.Z, Values.Range.Value.Direction.Z)) * CFrame.Angles(math.random(-math.pi, math.pi), math.random(-math.pi, math.pi), math.random(-math.pi, math.pi))
			v.RandomOffset = RandomOffset
			local TargetPoint = ((CFrame.new(Values.Target.Value.Position) * CFrame.new(Values.TargetOffset.Value)) * RandomOffset)
			TargetPoint = (TargetPoint * CFrame.Angles(0, 0, 0))
			v.Origin.CFrame = TargetPoint
			v.BodyGyro.cframe = (CFrame.new(v.Torso.Position, TargetPoint.p) * CFrame.Angles(-(math.pi / 2), 0, 0))
			v.BodyPosition.position = TargetPoint.p
			if v.Origin.CFrame and (v.Torso.Position - v.Origin.CFrame.p).magnitude <= 6 then
				v.BodyPosition.P = 5000
				v.Traveling = false
				v.Origin.Nearby = true
			else
				v.BodyPosition.P = 25000
			end
		else
			v.Origin.Nearby = false
		end
	end
end

function BatTouched(Bat)
	if not Bat or not Bat.Parent then
		return
	end
	local HitDelayed = true
	for i, v in pairs(Bat:GetChildren()) do
		if v:IsA("BasePart") then
			v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent or not HitDelayed then
					return
				end
				local character = Hit.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health == 0 then
					return
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player == Creator or Functions.IsTeamMate(Creator, player) then
					return
				end
				local creator = character:FindFirstChild("Creator")
				if creator and creator:IsA("ObjectValue") and creator.Value == Creator then
					return
				end
				HitDelayed = true
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, Creator)
				humanoid:TakeDamage(Values.Damage.Value)
				wait(0.25)
				HitDelayed = false
			end)
		end
	end
end

function FunctionBats()
	Spawn(function()
		local LastFlyUpdate = 0
		local SoundPlayedLast = 0
		local MaintainPosition = 0
		local FlapCheck = 0
		while true do
			local Now = tick()
			local CanFlap = false
			if (Now - LastFlyUpdate) >= 0.5 then
				LastFlyUpdate = Now
				PositionBats()
			end
			for i, v in pairs(Scythes) do
				FlyScythe(v)
			end
			if (Now - FlapCheck) >= 0.25 then
				CanFlap = true
				FlapCheck = Now
			end
			for i, v in pairs(Bats) do
				if v and v.Bat.Parent then
					if (Now - v.SoundPlayedLast) >= 1 then
						v.SoundPlayedLast = Now
						local PlaySound = math.random(1, 5)
						if PlaySound == 5 then
							local PossibleSounds = {}
							for i, v in pairs(Sounds:GetChildren()) do
								if v:IsA("Sound") then
									table.insert(PossibleSounds, v)
								end
							end
							local Sound = PossibleSounds[math.random(1, #PossibleSounds)]
							local TempSound = Sound:Clone()
							Debris:AddItem(TempSound, 2.5)
							TempSound.Parent = v.Torso
							TempSound:Play()
						end
					end
					if (Now - MaintainPosition) >= 0.35 and v.RandomOffset then
						local TargetPoint = ((CFrame.new(Values.Target.Value.Position) * CFrame.new(Values.TargetOffset.Value)) * v.RandomOffset)
						TargetPoint = (TargetPoint * CFrame.Angles(0, 0, 0))
	--					v.BodyGyro.cframe = (CFrame.new(v.Torso.Position, TargetPoint.p) * CFrame.Angles(-(math.pi / 2), 0, 0))
	--					v.BodyPosition.position = TargetPoint.p
					end
					if CanFlap then
						local LeftWing = v.Torso:FindFirstChild("Left Shoulder")
						local RightWing = v.Torso:FindFirstChild("Right Shoulder")
						for ii, vv in pairs({LeftWing, RightWing}) do
							if vv then
								vv.MaxVelocity = 0.1
								if vv.DesiredAngle == 0 then
									vv.DesiredAngle = 0.5
								else
									vv.DesiredAngle = (vv.DesiredAngle * -1)
								end
							end
						end
					end
				end
			end
			wait(0.25)
		end
	end)
end

FunctionsModule = script:FindFirstChild("Functions")
Sounds = script:FindFirstChild("Sounds")

if not FunctionsModule or not Sounds or not Values.Creator or not Values.Creator.Value or not Values.Tool or not Values.Tool.Value or not Values.Target or not Values.Target.Value or not Values.TargetOffset or not Values.Range.Value then
	DestroyModel()
	return
end

Functions = require(FunctionsModule)

Creator = Values.Creator.Value
Tool = Values.Tool.Value

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator or not Creator.Parent then
		DestroyModel()
	elseif Property == "Character" and not Creator.Character or not Creator.Character.Parent then
		DestroyModel()
	end
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyModel()
	end
end)

Values.Target.Changed:connect(function(Property)
	if not Values.Target.Value or not Values.Target.Value.Parent then
		DestroyModel()
	end
end)

for i, v in pairs(Model:GetChildren()) do
	ChildAdded(v)
end

Model.ChildAdded:connect(ChildAdded)
Model.ChildRemoved:connect(ChildRemoved)

FunctionBats()

wait(1)
RemoveModel()