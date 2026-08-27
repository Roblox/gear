--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))
CameraFixer = script:WaitForChild("CameraFixer")
Sparks = script:WaitForChild("Sparks")
Fire = script:WaitForChild("Fire")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

Grips = {
	Unequipped = CFrame.new(0, -0.4, 0.9, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.1, -0.4, 1.25, 0.85, -0, 0.525, 0, 1, 0, -0.525, 0, 0.85),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Manual = false},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75, Manual = false},
}

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	Shot = Handle:WaitForChild("Shot"),
	Reload = Handle:WaitForChild("Reload"),
	Reload2 = Handle:WaitForChild("Reload2"),
}

Configuration = {
	Accuracy = {
		Max = Vector3.new(0.375, 0.375, 0.375),
	},
	Damage = {
		Base = 22,
		Distance = {Min = 0, Max = 18},
		Multiplier = 0.75,
		Critical = {Chance = 8, Damage = {Min = 15, Max = 25}},
	},
	--WindVec = Vector3.new(2, 1, 1).Unit,
	FireRate = 2,
	Range = 350,
	FadeRate = 1.125,
	FiringOffset = CFrame.new((Handle.Size.X * 2), 0.1, -(Handle.Size.Z / 2)),
}

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function LaserTouched(Hit, StartPos, EndPos)
	if not Hit or not Hit.Players then
		return
	end
	local HitObject = Hit.Object
	if HitObject and HitObject.Parent then
		local HitCharacter = HitObject.Parent
		if HitCharacter:IsA("Hat") or HitCharacter:IsA("Tool") then
			HitCharacter = HitCharacter.Parent
		end
		local HitHumanoid = nil
		for i, v in pairs(HitCharacter:GetChildren()) do
			if v:IsA("Humanoid") then
				HitHumanoid = v
			end
		end
		if not HitHumanoid then
			local ParticlePart = BasePart:Clone()
			ParticlePart.Name = "Effect"
			ParticlePart.Transparency = 1
			ParticlePart.Anchored = true
			ParticlePart.CanCollide = false
			local Color = BrickColor.new("Magenta")
			local Particles = Sparks:Clone()
			Particles.Color = ColorSequence.new(Color.Color, Color.Color)
			Particles.Enabled = true
			local Duration = Create("NumberValue"){
				Name = "Duration",
				Value = 0.5,
				Parent = Particles,
			}
			local ParticleScript = Particles:FindFirstChild("ParticleScript")
			if ParticleScript then
				ParticleScript.Disabled = false
			end
			Particles.Parent = ParticlePart
			Debris:AddItem(ParticlePart, 1.5)
			ParticlePart.Parent = game:GetService("Workspace")
			ParticlePart.CFrame = ((CFrame.new(EndPos, StartPos) * CFrame.new(0, ParticlePart.Size.Y, 0)) * CFrame.Angles(-(math.pi / 2), 0, 0))
		end
	end
	for i, v in pairs(Hit.Players) do
		if v.Humanoid and v.Hit then
			local humanoid = v.Humanoid
			local character = humanoid.Parent
			local torso = character:FindFirstChild("Torso")
			if not humanoid or humanoid.Health == 0 or not torso then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and Functions.IsTeamMate(Player, player) then
				return
			end
			local RayDistance = (StartPos - EndPos).Magnitude
			local Damage = Configuration.Damage
			local DistanceDamage = Round(Clamp(GetPercentage(0, (Configuration.Range / 2), RayDistance), Damage.Distance.Min, Damage.Distance.Max), 0.5)
			local DeterminedDamage = (Damage.Base)
			DeterminedDamage = (DeterminedDamage + DistanceDamage)
			local CriticalChance = math.random(1, Damage.Critical.Chance)
			if CriticalChance == 1 then
				DeterminedDamage = (DeterminedDamage + math.random(Damage.Critical.Damage.Min, Damage.Critical.Damage.Max))
			end
			if v.Hit.Name == "Head" then
				DeterminedDamage = Clamp((DeterminedDamage * (1 + Damage.Multiplier)), 0, 100)
			end
			local HealthAfter = (humanoid.Health - DeterminedDamage)
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DeterminedDamage)
			if HealthAfter <= 0 then
				for i, v in pairs(character:GetChildren()) do
					if v:IsA("BasePart") and v.Transparency < 1 then
						local FireCopy = Fire:Clone()
						FireCopy.Enabled = true
						FireCopy.Parent = v
					end
				end
			end
		end
	end
end

function FireLaser(StartPosition, TargetPosition)
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	local RayHit, RayPos, RayNormal = Functions.CastRay(StartPosition, Direction, Configuration.Range, {Character}, false)
	local RayLength = (StartPosition - RayPos).Magnitude
	Direction = CFrame.new(StartPosition, RayPos)
	local Laser = BasePart:Clone()
	local FadeDuration = Configuration.FadeRate
	local FadeRate = 10
	local Laser = BasePart:Clone()
	Laser.Name = "Laser"
	Laser.BrickColor = BrickColor.new("Magenta")
	Laser.Transparency = 0
	Laser.Material = Enum.Material.Neon
	Laser.Size = Vector3.new(0.2, 0, RayLength)
	Laser.CFrame = (Direction * CFrame.new(0, 0, -(RayLength / 2)))
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Create("CylinderMesh"){
		Name = "Mesh",
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Laser,
	}
	for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
		local Light = Create("SurfaceLight"){
			Name = "Light",
			Color = Laser.BrickColor.Color,
			Face = Enum.NormalId[v],
			Brightness = 100,
			Range = 3,
			Shadows = false,
			Enabled = true,
			Parent = Laser,
		}
	end
	local OrigCF = Laser.CFrame
	Laser.Size = Vector3.new(Laser.Size.X, Laser.Size.Z, Laser.Size.Y)
	Laser.CFrame = (OrigCF * CFrame.Angles((math.pi / 2), 0, 0))
	Debris:AddItem(Laser, FadeDuration)
	Laser.Parent = game:GetService("Workspace")
	LaserTouched(RayHit, StartPosition, RayPos)
	Spawn(function()
		local FadeRate = 0.05
		local TimeToFade = 1
		local OrigTransparency = Laser.Transparency
		local TotalFade = (TimeToFade / FadeRate)
		for i = 1, TotalFade do
			if not Laser or not Laser.Parent or Laser.Transparency >= 1 then
				break
			end
			wait(FadeRate)
			--Laser.CFrame = (Laser.CFrame + Configuration.WindVec * FadeRate)
			Laser.Transparency = (OrigTransparency + (i / (TimeToFade / FadeRate)))
			for ii, vv in pairs(Laser:GetChildren()) do
				if vv:IsA("Light") then
					vv.Brightness = (50 - (50 * (GetPercentage(0, 1, Laser.Transparency) * 0.01)))
					if vv.Brightness <= 0 then
						vv.Enabled = false
					end
				--[[elseif vv:IsA("DataModelMesh") then
					local NewScale = (1 - (1 * (GetPercentage(0, 1, Laser.Transparency) * 0.01)))
					vv.Scale = Vector3.new(NewScale, vv.Scale.Y, NewScale)]]
				end
			end
		end
	end)
end

function Activated(Data)
	if not Tool.Enabled or not CheckIfAlive() or not Data or not Data.TargetData or not Data.TargetData.Position then
		return
	end
	Tool.Enabled = false
	local TargetData = Data.TargetData
	local ExtraData = Data.ExtraData
	local FireSound = Sounds.Shot:Clone()
	Debris:AddItem(FireSound, 1.25)
	FireSound.Parent = Handle
	FireSound:Play()
	local StartPosition = (Handle.CFrame * Configuration.FiringOffset).p
	local TargetPosition = TargetData.Position
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Fire)
	end)
	local Accuracy = (Configuration.Accuracy.Max * 100)
	if ExtraData.Zoom then
		Accuracy = (Configuration.Accuracy.Max * (1 - ((ExtraData.Zoom.Percent * 0.01) + 0)))
	end
	TargetPosition = TargetPosition + Vector3.new((math.random(-Accuracy.X, Accuracy.X) * 0.01), (math.random(-Accuracy.Y, Accuracy.Y) * 0.01), (math.random(-Accuracy.Z, Accuracy.Z) * 0.01))
	FireLaser(StartPosition, TargetPosition)
	wait(Configuration.FireRate / 2)
	Sounds.Reload2:Play()
	wait(Configuration.FireRate / 2)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Sounds.Equip:Play()
	Tool.Grip = Grips.Equipped
	Spawn(function()
		local CameraFixScript = CameraFixer:Clone()
		CameraFixScript.Name = (Player.Name .. "'s" .. CameraFixer.Name)
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = CameraFixScript,
			}
		end
		CameraFixScript.Disabled = false
		CameraFixScript.Parent = game:GetService("Workspace")
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "MouseClick" then
		local Down = value.Down
		local Data = value.Data
		if Down and Data then
			Activated(Data)
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)