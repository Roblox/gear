--Made by Luckymaxer

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


DamageValues = {
	BaseDamage = 8,
	SlashDamage = 12,
	LungeDamage = 16,
}

Damage = DamageValues.BaseDamage

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")
Animations = {
	R6Unsheath = {Animation = R6Anims:WaitForChild("Unsheath"), FadeTime = nil, Weight = nil, Speed = nil},
	R6Lunge = {Animation = R6Anims:WaitForChild("Lunge"), FadeTime = nil, Weight = nil, Speed = nil},
	R6Idle = {Animation = R6Anims:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil},
	R6OverheadSlash = {Animation = R6Anims:WaitForChild("OverheadSlash"), FadeTime = nil, Weight = nil, Speed = nil},
	R6Slash = {Animation = R6Anims:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Unsheath = {Animation = R15Anims:WaitForChild("Unsheath"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Lunge = {Animation = R15Anims:WaitForChild("Lunge"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Idle = {Animation = R15Anims:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil},
	R15OverheadSlash = {Animation = R15Anims:WaitForChild("OverheadSlash"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Slash = {Animation = R15Anims:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	OverheadSlash = Handle:WaitForChild("OverheadSlash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

LastAttack = 0
Attacks = 0

ToolEquipped = false

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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
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
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health <= 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				v.Name = "Part"
				v.CanCollide = false
				v:BreakJoints()
				if v.Transparency < 1 then
					local Gravity = 196.20
					local Weight = (v:GetMass() * Gravity)
					local Speed = 50
					local Direction = (CFrame.new() * CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))).lookVector --CFrame.new(Handle.Position, v.Position).lookVector
					local Velocity = ((Direction + Vector3.new(0, (math.random(35, 60) * 0.01), 0)) * Speed)
					v.BrickColor = BrickColor.new("Really black")
					v.Material = Enum.Material.Neon
					v.Transparency = 0.1
					v.Velocity = Velocity
					Debris:AddItem(v, 3)
				end
			end
		end
	end
end

function Slash()
	Damage = DamageValues.SlashDamage
	
	local SlashAnim = Animations.R6Slash
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		SlashAnim = Animations.R15Slash
	end
	Spawn(function()
		InvokeClient("PlayAnimation", SlashAnim)
	end)
	
	Sounds.Slash:Play()
	
	wait(0.5)
	
end

function OverheadSlash()
	Damage = DamageValues.SlashDamage
	
	local OverheadSlashAnim = Animations.R6OverheadSlash
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		OverheadSlashAnim = Animations.R15OverheadSlash
	end
	Spawn(function()
		InvokeClient("PlayAnimation", OverheadSlashAnim)
	end)
	
	Sounds.OverheadSlash:Play()
	
	wait(0.5)
	
end

function Lunge()
	Damage = DamageValues.LungeDamage
	
	local LungeAnim = Animations.R6Lunge
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		LungeAnim = Animations.R15Lunge
	end
	Spawn(function()
		InvokeClient("PlayAnimation", LungeAnim)
	end)
	Sounds.Lunge:Play()
	
	wait(1)

	Damage = DamageValues.SlashDamage
end

function Attack()
	local Tick = tick()
	if (Tick - LastAttack) < 1.5 and Attacks > 0 and Attacks < 3 then
		if Attacks == 1 then
			Tool.Enabled = false
			Lunge()
			Tool.Enabled = true
		elseif Attacks == 2 then
			Tool.Enabled = false
			OverheadSlash()
			Tool.Enabled = true
		end
	else
		Tool.Enabled = false
		Slash()
		Tool.Enabled = true
	end
	Attacks = (Attacks + 1)
	if Attacks >= 3 then
		Attacks = 0
	end
	LastAttack = Tick
end

function Activated()

	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end

	Tool.Enabled = false

	Attack()

	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	local UnsheathAnim = Animations.R6Unsheath
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		UnsheathAnim = Animations.R15Unsheath
	end
	Spawn(function()
		InvokeClient("PlayAnimation", UnsheathAnim)
	end)
	local IdleAnim = Animations.R6Idle
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		IdleAnim = Animations.R15Idle
	end
	Spawn(function()
		InvokeClient("PlayAnimation", IdleAnim)
	end)
	ToolEquipped = true
	Sounds.Unsheath:Play()
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Connection = Handle.Touched:connect(Blow)