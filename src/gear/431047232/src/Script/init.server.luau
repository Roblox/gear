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


FreezeScript = script:WaitForChild("FreezeScript")
BlizzardGui = script:WaitForChild("BlizzardGui")

BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = workspace.Gravity

Rate = (1 / 60)

DamageValues = {
	BaseDamage = 5,
	SlashDamage = 8,
	LungeDamage = 12
}

Damage = DamageValues.BaseDamage

Grips = {
	Up = CFrame.new(0, -1.60000002, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -1.60000002, 0, 1, 0, 0, 0, 0.00900864415, -0.999959409, -0, 0.999959528, 0.00900864322),
}

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

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Solidify = Handle:WaitForChild("Solidify"),
	IceShatter = Handle:WaitForChild("IceShatter")
}

HitDebounce = false
ToolEquipped = false

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		v.Enabled = true
	end
end

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

function Attack(PossibleAnims)
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
		wait(Animation.Duration)
		CurrentAnimation = nil
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
end

function CoolNearby(Radius)
	local function CoolPlayers()
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= Player and not IsTeamMate(Player, v) and v.Character then
				local character = v.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and torso then
					local DistanceApart = (Handle.Position - torso.Position).Magnitude
					if DistanceApart <= Radius then
						local PlayerGui = v:FindFirstChild("PlayerGui")
						if PlayerGui then
							local Gui = PlayerGui:FindFirstChild(BlizzardGui.Name)
							if Gui then
								local Timer = Gui:FindFirstChild("Timer")
								if Timer then
									Timer.Value = tick()
								end
							end
							if not Gui then
								Gui = BlizzardGui:Clone()
								local Timer = Gui:FindFirstChild("Timer")
								if Timer then
									Timer.Value = tick()
								end
								for i, v in pairs(Gui:GetChildren()) do
									if v:IsA("BaseScript") then
										v.Disabled = false
									end
								end
								Gui.Parent = PlayerGui
							end
						end
					end
				end
			end
		end
	end
	RunService.Stepped:connect(function()
		if ToolEquipped and CheckIfAlive() then
			CoolPlayers()
		end
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Slash"
	Anim.Parent = Tool
end

function Lunge()
	Damage = DamageValues.LungeDamage

	Sounds.Lunge:Play()

	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Lunge"
	Anim.Parent = Tool
	
	wait(0.2)
	Tool.Grip = Grips.Out
	wait(0.6)
	Tool.Grip = Grips.Up

	Damage = DamageValues.SlashDamage
end

Tool.Enabled = true
LastAttack = 0

function Activated()

	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end

	Tool.Enabled = false

	Tick = RunService.Stepped:wait()

	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end

	LastAttack = Tick

	--wait(0.5)

	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	ToolEquipped = true
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

Handle.Touched:connect(Blow)

Spawn(function()
	CoolNearby(10)
end)

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)
Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)