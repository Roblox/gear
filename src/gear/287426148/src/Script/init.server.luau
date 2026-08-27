--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RemoverScript = script:WaitForChild("RemoverScript")
ParticleScript = script:WaitForChild("ParticleScript")
ParticleFire = script:WaitForChild("Fire")

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

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 5, Max = 8},
	Hit = {Min = 18, Max = 22},
}

FireDamage = 5

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Grips = {
	Up = CFrame.new(0, -2.35, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -2.35, 0.25, 1, 0, 0, 0, 0, -1, -0, 1, 0),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	Lunge = {Animation = Tool:WaitForChild("Lunge"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

LastAttack = 0

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 20,
}

Particles = {}

Lunging = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

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

function Swing(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		Delay(Animation.Duration, (function()
			CurrentAnimation = nil
		end))
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DamageValue)
	if HealthAfter > 0 then
	end
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Lunge(MousePosition)
	Lunging = true
	for i, v in pairs(Animations) do
		Spawn(function()
			InvokeClient("StopAnimation", v)
		end)
	end
	Sounds.Lunge:Play()
	Tool.Grip = Grips.Out
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, 0, Mass),
		velocity = (Direction.lookVector * 100),
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
	}
	for i, v in pairs({BodyVelocity, BodyGyro}) do
		Debris:AddItem(v, 0.5)
		v.Parent = Torso
	end
	wait(0.75)
	Tool.Grip = Grips.Up
	wait(0.5)
	Lunging = false
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

function ParticleHit(Part)
	local HitDebounce = false
	local TouchedConnection
	TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or HitDebounce then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		if not Special.Active then
			HitDebounce = true
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(FireDamage * ((Special.Active and 2.5) or 1))
		local Fire = Part:FindFirstChild("Fire")
		if Fire then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BasePart") and not v:FindFirstChild("EffectFire") then
					local FireCopy = ParticleFire:Clone()
					FireCopy.Name = "EffectFire"
					FireCopy.Color = ColorSequence.new(Fire.Color, Fire.Color)
					FireCopy.Enabled = true
					local ParticleScriptCopy = ParticleScript:Clone()
					local Duration = Create("NumberValue"){
						Name = "Duration",
						Value = 4,
						Parent = FireCopy,
					}
					ParticleScriptCopy.Disabled = false
					ParticleScriptCopy.Parent = FireCopy
					Debris:AddItem(FireCopy, 5)
					FireCopy.Parent = v
				end
			end
		end
		wait(0.5)
		HitDebounce = false
	end)
	return
end

function CreateParticles()
	Particles = {}
	local ModelName = (Player.Name .. "'s Particles")
	local ParticleRadius = 5
	local ParticleModel = Create("Model"){
		Name = ModelName,
	}
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	local RemoverScriptCopy = RemoverScript:Clone()
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = RemoverScriptCopy,
		}
	end
	RemoverScriptCopy.Disabled = false
	RemoverScriptCopy.Parent = ParticleModel
	local OrbitingVelocity = 15
	local Radius = 7.5
	local RadiusSquared = (Radius ^ 2)
	local OrbitingVelocitySquared = (OrbitingVelocity ^ 2)
	local Count = 40
	local Colors = {"Really red", "Really blue", "Deep orange"}
	local Now = tick()
	for i = 1, Count do
		local ParticlePart = BasePart:Clone()
		ParticlePart.Name = "Effect"
		ParticlePart.Transparency = 1
		ParticlePart.Size = Vector3.new(1, 1, 1)
		ParticlePart.CanCollide = false
		local FireColor = BrickColor.new(Colors[math.random(1, #Colors)]).Color
		local Fire = Create("Fire"){
			Color = FireColor,
			SecondaryColor = FireColor,
			Heat = 2,
			Size = 3,
			Enabled = true,
			Parent = ParticlePart,
		}
		local Mass = ParticlePart:GetMass()
		local SpawnPos = Torso.Position
		local OrbitingVelocity = 15
		local Theta = (i / 20 * 2 * math.pi)
		local NewVelocity = Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5))
		local UnitVectorTowardsUs = Vector3.new((Radius * math.cos(Theta)), 0, (Radius * math.sin(Theta))).Unit
		NewVelocity = (NewVelocity - UnitVectorTowardsUs * NewVelocity:Dot(UnitVectorTowardsUs))
		ParticlePart.Velocity = (NewVelocity.Unit * OrbitingVelocity)
		ParticlePart.RotVelocity = Vector3.new(((math.random() - 0.5) * 10), ((math.random() - 0.5) * 10), ((math.random() - 0.5) * 10))
		local Force = Create("BodyForce"){
			force = Vector3.new((-Mass * OrbitingVelocity * OrbitingVelocity * math.cos(Theta) / RadiusSquared), (Mass * Gravity), (-Mass * OrbitingVelocity * OrbitingVelocity * math.sin(Theta) / RadiusSquared)),
			Parent = ParticlePart,
		}
		local Position = Create("BodyPosition"){
			maxForce = Vector3.new(0, 0, 0),
			Parent = ParticlePart,
		}
		ParticlePart.CFrame = CFrame.new((SpawnPos.X + Radius * math.cos(Theta)), SpawnPos.Y, (SpawnPos.Z + Radius * math.sin(Theta)))
		ParticlePart.Parent = ParticleModel
		table.insert(Particles, {Part = ParticlePart, Force = Force, Position = Position, Fire = {Object = Fire, LastChange = Now}})
		ParticleHit(ParticlePart)
	end
	ParticleModel.Parent = game:GetService("Workspace")
	while ParticleModel and ParticleModel.Parent do
		local Now = tick()
		for i, v in pairs(Particles) do
			local MPos = Torso.Position
			local DPos = (v.Part.Position - MPos)
			local Mass = v.Part:GetMass()
			local UnitVectorTowardsUs = DPos.Unit
			if DPos.Magnitude <= (Radius + 2) then
				v.Position.maxForce = Vector3.new(0, 0, 0)
				v.Force.force = (Mass * Vector3.new((-OrbitingVelocitySquared * DPos.X / RadiusSquared), (-OrbitingVelocitySquared * DPos.Y / RadiusSquared + Gravity), (-OrbitingVelocitySquared * DPos.Z / RadiusSquared)))
				local NewVelocity = (v.Part.Velocity - ( 1 / (1 + math.abs(DPos.Magnitude - Radius))) * UnitVectorTowardsUs * v.Part.Velocity:Dot(UnitVectorTowardsUs))
				v.Part.Velocity = (NewVelocity.Unit * OrbitingVelocity * Vector3.new(1, 1, 1))
			else
				local Mass = (v.Part:GetMass() * Gravity * math.random(75, 100))
				v.Force.force = Vector3.new(0, 0, 0)
				v.Position.maxForce = Vector3.new(Mass, Mass, Mass)
				v.Position.position = (Torso.CFrame + (Torso.CFrame * CFrame.Angles((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01) ,(math.random(-360, 360) * 0.01))).lookVector * Radius).p
			end
			if (Now - v.Fire.LastChange) >= 2 then
				v.Fire.LastChange = Now
				Spawn(function()
					local NewColor = BrickColor.new(Colors[math.random(1, #Colors)]).Color
					local TransformRate = 1
					Spawn(function()
						TweenColor(v.Fire.Object, "Color", v.Fire.Object.Color, NewColor, TransformRate)
					end)
					Spawn(function()
						TweenColor(v.Fire.Object, "SecondaryColor", v.Fire.Object.SecondaryColor, NewColor, TransformRate)
					end)
				end)
			end
		end
		wait(0.01)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Attack()
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
	Swing(AttackAnims)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false 
	local Time = RunService.Stepped:wait()
	if (Time - LastAttack) < 0.2 then
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			Lunge(MousePosition.Position)
		end
	else
		Attack()
	end
	LastAttack = Time
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		Tool.Grip = Grips.Up
		if not Special.Active then
			CreateParticles()
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down then
			if not Special.Enabled or Special.Active then
				return
			end
			local TargetPosition = InvokeClient("MousePosition")
			if not TargetPosition then
				return
			end
			TargetPosition = TargetPosition.Position
			Special.Enabled = false
			Special.Active = true
			for i, v in pairs(Particles) do
				if v and v.Part and v.Part.Parent then
					local Particle = v.Part:Clone()
					if v.Part and v.Part.Parent then
						v.Part:Destroy()
					end
					ParticleHit(Particle)
					Particle.Name = "Effect"
					for i, v in pairs(Particle:GetChildren()) do
						if string.find(string.lower(v.ClassName), string.lower("Body")) then
							v:Destroy()
						end
					end
					v.Fire.Object.Heat = 15
					v.Fire.Object.Size = 5
					local Direction = CFrame.new(Particle.Position, TargetPosition)
					local Mass = (Particle:GetMass() * Gravity)
					local Force = 100
					local Velocity = (Direction.lookVector * Force)
					local BodyVelocity = Create("BodyVelocity"){
						maxForce = Vector3.new(Mass, Mass, Mass),
						velocity = Velocity,
						Parent = Particle,
					}
					Particle.RotVelocity = Vector3.new(0, 0, 0)
					Particle.Velocity = Velocity
					Debris:AddItem(Particle, 3)
					Particle.Parent = game:GetService("Workspace")
				end
			end
			wait(Special.ReloadTime)
			Special.Active = false
			if ToolEquipped and CheckIfAlive() then
				CreateParticles()
			end
			Special.Enabled = true
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)