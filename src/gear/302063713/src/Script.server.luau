--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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

Grips = {
	Unequipped = CFrame.new(0, -1.25, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0, -1.25, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = 0.1, Weight = nil, Speed = 0.5, Duration = nil},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = 0.8},
	Summon = {Animation = Tool:WaitForChild("Summon"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 0.85, Duration = nil},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Swipe1 = Handle:WaitForChild("Swipe1"),
	Swipe2 = Handle:WaitForChild("Swipe2"),
	Swipe3 = Handle:WaitForChild("Swipe3"),
	Swipe4 = Handle:WaitForChild("Swipe4"),
}

Particles = {
	Ghosts = Handle:WaitForChild("Ghosts"),
	KillEffect = Handle:WaitForChild("KillEffect"),
}

Damages = {
	Touch = 0,
	Slash = 15,
	Spin = 22,
}

CurrentDamage = Damages.Touch

Spinning = false
ToolEquipped = false

Tool.Enabled = true
Tool.Grip = Grips.Unequipped

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

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

function PartTouched(Part)
	local TouchedConnection
	local TouchDebounce = false
	TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or TouchDebounce then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or RightGrip.Part0 ~= RightArm or RightGrip.Part1 ~= Handle then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if not humanoid or humanoid.Health == 0 or not Torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		TouchDebounce = true
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(CurrentDamage)
		if Spinning then
			torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * 75)
		end
		if humanoid.Health <= 0 then
			Particles.KillEffect:Emit(500)
		end
		wait(0.25)
		TouchDebounce = false
	end)
	return TouchedConnection
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	CurrentDamage = Damages.Slash
	local SlashSounds = {Sounds.Swipe1, Sounds.Swipe2, Sounds.Swipe3, Sounds.Swipe4}
	SlashSounds[math.random(1, #SlashSounds)]:Play()
	local Animation = Animations.Slash
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	local SpinChance = math.random(1, 3)
	if SpinChance == 1 then
		Spinning = true
		CurrentDamage = Damages.Spin
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Spin)
		end)
	end
	wait(Animation.Duration)
	Spinning = false
	CurrentDamage = Damages.Touch
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
	ToolEquipped = true
	Spinning = false
	Tool.Grip = Grips.Equipped
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Idle)
	end)
	Sounds.Unsheath:Play()
end

function Unequipped()
	Spinning = false
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
	elseif mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

PartTouched(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke