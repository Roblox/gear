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


Grips = {
	Up = CFrame.new(0, -1.5, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0),
	Out = CFrame.new(0, -1.5, 0, 1, -0, -0, -0, 0, -1, 0, 1, -0),
}

DamageValues = {
	BaseDamage = 8,
	SlashDamage = 14,
}

Damage = DamageValues.BaseDamage

Gravity = 196.20

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
	Whack = {Animation = Tool:WaitForChild("Whack"), FadeTime = 0.125, Weight = nil, Speed = 2, Duration = 0.75},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Unsheath = Handle:WaitForChild("Unsheath"),
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

PushForce = 25

LastAttack = 0

Spinning = false
ToolEquipped = false

Tool.Enabled = true

function PerformEggHuntFunctions()
	local function LinkToPlayer(player)
		pcall(function()
			local Module = require(376407361)
			if Module then
				local GearData = Module.GetGear({Player = player, Key = "EggBeater", Tool = Tool})
				if GearData then
					GearFunctions = GearData.LinkWithPlayer({Player = player})
				end
			end
		end)
	end
	local function UnlinkFromPlayer()
		if not GearFunctions then
			return
		end
		GearFunctions.UnlinkFromPlayer()
	end
	local function CanDamage(humanoid)
		if not GearFunctions then
			return false
		end
		return GearFunctions.IsAllowedToKill(humanoid)
	end
	local function GetVariables()
		if not GearFunctions or not GearFunctions.Variables then
			return
		end
		local Variables = GearFunctions.Variables
		PushForce = Variables.PushForce
		DamageValues = Variables.DamageValues
	end
	return {
		LinkToPlayer = LinkToPlayer,
		UnlinkFromPlayer = UnlinkFromPlayer,
		CanDamage = CanDamage,
		GetVariables = GetVariables,
	}
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	local humanoid = nil
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("Humanoid") then
			humanoid = v
			break
		end
	end
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health <= 0 or not Torso then
		return
	end
	if not EggHuntFunctions.CanDamage(humanoid) then
		return
	end
	if Spinning then
		torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * PushForce)
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
end

function Slash()
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Grip = Grips.Out
	Damage = DamageValues.SlashDamage
	local Animation = Animations.Whack
	Sounds.Slash:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	Spinning = true
	local SpinFrames = 30
	for i = 1, 3 do
		for ii = 1, SpinFrames do
			Tool.Grip = (Tool.Grip * CFrame.Angles(0, 0, (((math.pi * 2) / SpinFrames) * ii)))
			RunService.Stepped:wait()
			if not CurrentlyEquipped then
				break
			end
		end
		if not CurrentlyEquipped then
			break
		end
	end
	Spinning = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	wait(Animation.Duration)
	wait(0.5)
	Tool.Grip = Grips.Up
end

function Attack()
	--[[local Time = RunService.Stepped:wait()
	if (Time - LastAttack) < 0.2 then
		Lunge()
	else
		Spawn(Slash)
	end
	LastAttack = Time]]
	Slash()
	Damage = DamageValues.BaseDamage
end
	
function Lunge()
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
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	EggHuntFunctions.LinkToPlayer(Player)
	EggHuntFunctions.GetVariables()
	Tool.Grip = Grips.Up
	ToolEquipped = true
	Spawn(function()
		Sounds.Unsheath:Play()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
end

function Unequipped()
	EggHuntFunctions.UnlinkFromPlayer()
	Tool.Grip = Grips.Up
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

EggHuntFunctions = PerformEggHuntFunctions()

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)