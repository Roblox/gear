--Made by Luckymaxer
-- Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))
Sparks = script:WaitForChild("Sparks")

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

AnimationFolder = Tool.Animations

Grips = {
	Unequipped = CFrame.new(0, -0.4, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.1, -0.4, 0.5, 0.865, 0, 0.5, 0, 1, -0, -0.5, 0, 0.865),
	R15Equipped = CFrame.new(0.1, -0.4, 0.5, 0.931273937, 0, 0.364319861, 0.0891998336, 0.969563663, -0.228012443, -0.353231341, 0.244839311, 0.902929246)
}

Animations = {
	Equip = {Animation = AnimationFolder.R6:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Fire = {Animation = AnimationFolder.R6:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.75},
	R15Equip = {Animation = AnimationFolder.R15:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Fire = {Animation = AnimationFolder.R15:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.75},	
}

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	Shot = Handle:WaitForChild("Shot"),
	Reload = Handle:WaitForChild("Reload"),
	Reload2 = Handle:WaitForChild("Reload2"),
}

Configuration = {
	Damage = {
		Base = 6,
		Distance = {Min = 0, Max = 0},
		Multiplier = 0.30,
		Critical = {Chance = 8, Damage = {Min = 8, Max = 14}},
	},
	--WindVec = Vector3.new(2, 1, 1).Unit,
	Accuracy = 0.375,
	Spread = 2.5,
	Color = BrickColor.new("Bright red"),
	FireRate = 3,
	Burst = 5,
	Range = 75,
	FadeRate = 1.125,
	Clips = {Amount = 8, Rate = 0.5},
	FiringOffset = CFrame.new(0, 0.15, -(Handle.Size.Z * 0.5)),
}

ShotsFired = 0

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
		if HitCharacter:IsA("Accessory") or HitCharacter:IsA("Tool") then
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
			local Color = Configuration.Color
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
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
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
			end
		end
	end
end

function Reload(Override)
	if not Override and not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	wait(Configuration.FireRate / 2)
	Sounds.Reload2:Play()
	wait(Configuration.FireRate / 2)
	ShotsFired = 0
	Tool.Enabled = true
end

function FireLaser(StartPosition, TargetPosition)
	local Direction = CFrame.new(StartPosition, TargetPosition)
	local Spread = (Configuration.Spread * 100)
	local SpreadVector = (Vector3.new(math.rad(math.random(-Spread, Spread)), math.rad(math.random(-Spread, Spread)), math.rad(math.random(-Spread, Spread))) * 0.01)
	Direction = (Direction * CFrame.Angles(SpreadVector.X, SpreadVector.Y, SpreadVector.Z)).lookVector
	local RayHit, RayPos, RayNormal = Functions.CastRay(StartPosition, Direction, Configuration.Range, {Character}, false)
	local RayLength = (StartPosition - RayPos).Magnitude
	Direction = CFrame.new(StartPosition, RayPos)
	local Accuracy = (Configuration.Accuracy * 100)
	TargetPosition = (TargetPosition + (Vector3.new(math.random(-Accuracy, Accuracy), math.random(-Accuracy, Accuracy), math.random(-Accuracy, Accuracy)) * 0.01))
	local Laser = BasePart:Clone()
	local FadeDuration = Configuration.FadeRate
	local FadeRate = 10
	local Laser = BasePart:Clone()
	Laser.Name = "Laser"
	Laser.BrickColor = Configuration.Color
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

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	local FireSound = Sounds.Shot:Clone()
	Debris:AddItem(FireSound, 1.25)
	FireSound.Parent = Handle
	FireSound:Play()
	local StartPosition = (Handle.CFrame * Configuration.FiringOffset).p
	local TargetPosition = MouseData.Position
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	local Distance = (StartPosition - TargetPosition).Magnitude
	if Distance > Configuration.Range then
		TargetPosition = (CFrame.new(StartPosition) + Direction * Configuration.Range).p
	end
	Spawn(function()
		local Animation = Animations.Fire
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Fire
		end
		InvokeClient("PlayAnimation", Animations.Animation)
	end)
	for i = 1, Configuration.Burst do
		FireLaser(StartPosition, TargetPosition)
	end
	ShotsFired = (ShotsFired + 1)
	if ShotsFired >= Configuration.Clips.Amount then
		Reload(true)
	else
		wait(Configuration.Clips.Rate)
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Sounds.Equip:Play()
	Tool.Grip = Grips.Equipped
	Spawn(function()
		local Limbs = {"Left Arm", "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand"}
		for i, v in pairs(Limbs) do
			local Limb = Character:FindFirstChild(v)
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = true})
			end)
		end
		
		local Animation = Animations.Equip
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Equip
			Tool.Grip = Grips.R15Equipped
		end		
		InvokeClient("PlayAnimation", Animation)
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
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "r" and Down then
			Reload(false)
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