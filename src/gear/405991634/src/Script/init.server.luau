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
	SlashDamage = 17,
}

HitScript = script:WaitForChild("HitScript")
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
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	CannonShot = Handle:WaitForChild("CannonShot")
}

Grips = {
	Up = CFrame.new(0, -1.4375, -0.445, 1, 0, 0, 0, 0.75, -0.65, -0, 0.65, 0.75),
	Out = CFrame.new(0, -1.4375, -0.445, 1, 0, 0, 0, 0.75, -0.65, -0, 0.65, 0.75),
}

CannonBall = BasePart:Clone()
CannonBall.Name = "Projectile"
CannonBall.BrickColor = BrickColor.new("Sand green")
CannonBall.Material = Enum.Material.CorrodedMetal
CannonBall.Shape = Enum.PartType.Ball
CannonBall.FormFactor = Enum.FormFactor.Custom
CannonBall.Size = Vector3.new(1.75, 1.75, 1.75)
CannonBall.CanCollide = false
Create("Fire"){
	Name = "Fire",
	Color = Color3.new((0 / 255), (170 / 255), (0 / 255)),
	SecondaryColor = Color3.new((85 / 255), (255 / 255), (0 / 255)),
	Heat = 5,
	Size = 5,
	Enabled = true,
	Parent = CannonBall,
}

Gravity = 196.20
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

function ApplyDeathEffect(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local DeathEffectCopy = character:FindFirstChild(DeathEffect.Name)
	if DeathEffectCopy then
		return
	end
	DeathEffectCopy = DeathEffect:Clone()
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
		ApplyDeathEffect(character)
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
		local TotalDamage = Damage
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
	local SwingAnimations = {Animations.LeftSlash, Animations.RightSlash, Animations.Swing}
	local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
end

CannonballShot = false
CannonballReload = 8
function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		if not Tool.Enabled and not CannonballShot then
			CannonballShot = true
			Sounds.CannonShot.Pitch = (math.random(1250, 2000) * 0.001)
			Sounds.CannonShot:Play()
			local MousePosition = MouseData.Position
			local CannonBallCopy = CannonBall:Clone()
			local RemovalTime = 8
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = 65},
				{Name = "RemovalTime", Class = "NumberValue", Value = (RemovalTime - 3)},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = CannonBallCopy,
				}
			end
			local HitScriptCopy = HitScript:Clone()
			HitScriptCopy.Disabled = false
			HitScriptCopy.Parent = CannonBallCopy
			CannonBallCopy.CFrame = (Handle.CFrame * CFrame.new(0, 0, ((Handle.Size.Z / 2) + (CannonBallCopy.Size.Z / 2))))
			local Force = 150
			local Mass = (CannonBallCopy:GetMass() * Gravity)
			local Velocity = (CFrame.new(Handle.Position, MousePosition).lookVector * Force)
			local BodyVelocity = Create("BodyVelocity"){
				Name = "BodyVelocity",
				maxForce = Vector3.new(Mass, Mass, Mass),
				velocity = Velocity,
				Parent = CannonBallCopy,
			}
			CannonBallCopy.Velocity = Velocity
			Debris:AddItem(CannonBallCopy, RemovalTime)
			CannonBallCopy.Parent = game:GetService("Workspace")
			Delay(CannonballReload, (function()
				CannonballShot = false
			end))
		end
	else
		LastAttack = Tick
		if not Tool.Enabled then
			return
		end
		Tool.Enabled = false
		Attack()
		wait(0.65)
		Damage = DamageValues.BaseDamage
		Tool.Enabled = true
	end
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
	end)
end

function Unequipped()
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)