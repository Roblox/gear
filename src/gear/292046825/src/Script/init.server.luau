--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Sparks = script:WaitForChild("Sparks")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil, Manual = false},
}

Sounds = {
	Spin = Handle:WaitForChild("Spin"),
	Hit1 = Handle:WaitForChild("Hit1"),
	Hit2 = Handle:WaitForChild("Hit2"),
	Hit3 = Handle:WaitForChild("Hit3"),
}

BaseStar = Handle:Clone()
BaseStar.Name = "Projectile"
BaseStar.Transparency = 0
BaseStar.CanCollide = true
BaseStar.Locked = true
BaseStar.Anchored = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Rate = (1 / 30)
Gravity = 196.20

MaxDistance = 60
StarDamage = 30
ReloadTime = 1

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function ReadyNextStar()
	Handle.Transparency = 0
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function StarHit(Part, Hit, RepellingValue)
	if not Hit or not Hit.Parent then
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
	if player then
		if player == Player then
			if RepellingValue.Value then
				Part.Name = "Effect"
			end
			return
		elseif IsTeamMate(Player, player) then
			return
		end
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(StarDamage)
		RepellingValue.Value = true
		return true
	end
end

function FlyStar(Part)
	Spawn(function()
		local Repelling = Create("BoolValue"){
			Value = false,
		}
		local StartPosition = Part.Position
		local AlreadyHit = false
		Part.Touched:connect(function(Hit)
			if AlreadyHit then
				return
			end
			local SuccessfullyHit = StarHit(Part, Hit, Repelling)
			if SuccessfullyHit then
				AlreadyHit = true
			end
		end)
		while CheckIfAlive() and ToolEquipped and Part and Part.Parent and Part.Name ~= "Effect" and not Repelling.Value do
			local DistanceApart = (StartPosition - Part.Position).Magnitude
			if DistanceApart > MaxDistance then
				Repelling.Value = true
				break
			end
			local Directions = {{Vector = Part.Velocity.Unit, Length = 2.5}, {Vector = Vector3.new(0, -1, 0), Length = 1.5}}
			local ClosestRay = {DistanceApart = math.huge}
			for i, v in pairs(Directions) do
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {Character, Part}, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
			if ClosestRay.Hit then
				if AlreadyHit then
					return
				end
				local SuccessfullyHit = StarHit(Part, ClosestRay.Hit, Repelling)
				if SuccessfullyHit then
					AlreadyHit = true
				end
				--local PartCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
				--PartCFrame = (PartCFrame * CFrame.new(0, -(Part.Size.Y / 1.5), 0))
				--PartCFrame = (CFrame.new(PartCFrame.p, Handle.Position) * CFrame.Angles(0, math.pi, 0))
				Repelling.Value = true
				local HitSounds = {Part:FindFirstChild("Hit1"), Part:FindFirstChild("Hit2"), Part:FindFirstChild("Hit3")}
				local Sound = HitSounds[math.random(1, #HitSounds)]:Clone()
				Debris:AddItem(Sound, 1.5)
				Sound.Parent = Part
				Sound.Pitch = (math.random(900, 1200) * 0.001)
				Sound:Play()
				break
			end
			wait()
		end
		if Repelling.Value then
			while CheckIfAlive() and ToolEquipped and Part and Part.Parent and Part.Name ~= "Effect" and Repelling.Value do
				local DistanceApart = (Handle.Position - Part.Position).Magnitude
				if DistanceApart <= 3 then
					Part.Name = "Effect"
				else
					local Direction = CFrame.new(Part.Position, Handle.Position)
					local Force = 50
					local Velocity = (Direction.lookVector * Force)
					Part.Velocity = Velocity
				end
				wait()
			end
		end
		if Part and Part.Parent then
			if Part.Name == "Effect" then
				local SpinSound = Part:FindFirstChild("Spin")
				for i, v in pairs(Part:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
				if SpinSound then
					SpinSound.Volume = 0
					SpinSound:Stop()
				end
				Part.Name = "Effect"
				Part.Transparency = 1
				Part.CanCollide = false
				Part.Anchored = true
				Debris:AddItem(Part, 1.5)
			else
				Part:Destroy()
			end
		end
		ReadyNextStar()
	end)
end

function Shoot(TargetPos)
	
	local StartPos = Handle.CFrame
	local Direction = CFrame.new(StartPos.p, TargetPos)
	local Force = 50
	
	local Star = BaseStar:Clone()

	local SparkColor = BrickColor.new("New Yeller").Color
	local SparksCopy = Sparks:Clone()
	SparksCopy.Color = ColorSequence.new(SparkColor, SparkColor)
	SparksCopy.Enabled = true
	SparksCopy.Parent = Star
	
	local Mass = (Star:GetMass() * Gravity)	
	
	Star.Velocity = (Direction.lookVector * Force)
	Star.CanCollide = true
	Star.CFrame = (Direction + Direction.lookVector * 4.5)
	local Force = Create("BodyForce"){
		force = Vector3.new(0, Mass, 0),
		Parent = Star,
	}
	local Gyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		cframe = Direction,
		Parent = Star,
	}
	local RotVelocity = Create("BodyAngularVelocity"){
		maxTorque = Vector3.new(0, Mass, 0),
		angularvelocity = Vector3.new(0, 25, 0),
		Parent = Star,
	}
	FlyStar(Star)
	Debris:AddItem(Star, 5)
	Star.Parent = game:GetService("Workspace")
	local Sound = Star:FindFirstChild("Spin")
	if Sound then
		Sound:Play()
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local TargetPosition = MousePosition.Position
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Throw)
	end)
	Handle.Transparency = 1
	Shoot(TargetPosition)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)