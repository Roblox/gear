--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


DamageValues = {
	BaseDamage = 11,
	SlashDamage = 18,
	LungeDamage = 22,
}

Multiplier = {
	Kills = {Current = 0, Max = 3},
	Damage = 1.25,
}

FireParticle = script:WaitForChild("Fire")
DeathEffect = script:WaitForChild("DeathEffect")

Damage = DamageValues.BaseDamage

BaseUrl = "http://www.roblox.com/asset/?id="

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

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Grips = {
	Up = CFrame.new(0, -1.25, 0, 1, 0, -0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -1.25, 0, 1, 0, 0, 0, 0, -1, -0, 1, 0),
}

LastAttack = 0

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
Tool.Grip = Grips.Up
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

function ApplyDeathEffect(character, Direction, Force)
	local Direction = (Direction or Vector3.new(0, 0, 0))
	local Force = (Force or Vector3.new(0, 0, 0))
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local DeathEffectCopy = character:FindFirstChild(DeathEffect.Name)
	if DeathEffectCopy then
		return
	end
	DeathEffectCopy = DeathEffect:Clone()
	DeathEffectCopy.WindDirection.Value = Direction
	DeathEffectCopy.Force.Value = Force
	DeathEffectCopy.Disabled = false
	DeathEffectCopy.Parent = character
end

function DealDamage(character, damage)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		if Multiplier.Kills.Current < Multiplier.Kills.Max then
			Multiplier.Kills.Current = (Multiplier.Kills.Current + 1)
			Delay(15, (function()
				Multiplier.Kills.Current = (Multiplier.Kills.Current - 1)
			end))
		end
		local WindDir = (CFrame.new(Torso.Position, Vector3.new(torso.Position.X, Torso.Position.Y, torso.Position.Z)) * CFrame.Angles(0, math.pi, 0)).lookVector
		ApplyDeathEffect(character, Vector3.new(WindDir.X, 1, WindDir.Z), ((WindDir * 6.5) + Vector3.new(0, 15, 0)))
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Blow(Part)
	local PartTouched
	local HitDelay = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDelay then
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
		local torso = character:FindFirstChild("Torso")
		if not humanoid or humanoid.Health == 0 or not torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		local ChargePercent = (Clamp(GetPercentage(0, Multiplier.Kills.Max, Multiplier.Kills.Current), 0, 100) * 0.01)
		local BonusDamage = (Damage * (Multiplier.Damage * ChargePercent))
		local TotalDamage = (Damage + BonusDamage)
		print(BonusDamage)
		DealDamage(character, TotalDamage)
		wait(0.05)
		HitDelay = false
	end)
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	--[[local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
	}
	Debris:AddItem(Anim, 2)
	Anim.Parent = Tool]]
	local SwingAnimations = {Animations.LeftSlash, Animations.RightSlash, Animations.SideSwipe, Animations.Swing}
	local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
end

function Lunge()
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	for i, v in pairs(Animations) do
		Spawn(function()
			InvokeClient("StopAnimation", v)
		end)
	end
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Lunge",
	}
	Debris:AddItem(Anim, 2)
	Anim.Parent = Tool
	wait(0.2)
	Tool.Grip = Grips.Out
	wait(0.75)
	Tool.Grip = Grips.Up
	Damage = DamageValues.SlashDamage
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick
	--wait(0.5)
	Damage = DamageValues.BaseDamage
	Tool.Enabled = true
end

function CreateParticlePart(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	ParticlePart = BasePart:Clone()
	ParticlePart.Name = "Effect"
	ParticlePart.Transparency = 1
	ParticlePart.Size = Vector3.new(0.2, 2.5, 0.5)
	ParticlePart.CanCollide = false
	FireParticleCopy = FireParticle:Clone()
	FireParticleCopy.Enabled = true
	FireParticleCopy.Parent = ParticlePart
	Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = ParticlePart,
		C0 = CFrame.new(0, 0.625, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = ParticlePart,
	}
	ParticlePart.Parent = Tool
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		local Animation = Animations.Equip
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		ToolEquipped = true
		Humanoid.WalkSpeed = (16 * 1.25)
		CreateParticlePart(true)
	end)
end

function Unequipped()
	Humanoid.WalkSpeed = 16
	Spawn(function()
		CreateParticlePart(false)
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
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

ServerControl.OnServerInvoke = OnServerInvoke

Delay(0, (function()
	if not ToolEquipped then
		CreateParticlePart(false)
	end
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)