--Rescripted by Luckymaxer

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


Damages = {
	Touch = 5,
	Slash = 10,
	Explosion = 80
}

Damage = Damages.Touch

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	DualSlash = {Animation = Tool:WaitForChild("DualSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75},
	Dash = {Animation = Tool:WaitForChild("Dash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
	SwordPumpUp = {Animation = Tool:WaitForChild("SwordPumpUp"), FadeTime = nil, Weight = nil, Speed = 3, Duration = nil},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Spin = Handle:WaitForChild("Spin"),
	Whack = Handle:WaitForChild("Whack"),
	LineExplosion = Handle:WaitForChild("LineExplosion"),
}

LastDown = {
	W = 0,
	A = 0,
	D = 0,
}
DashTime = 0
LastSuperStrike = 0
LastSlash = 0

MaxDistance = 100

Balefire = {
	Enabled = true,
	ReloadTime = 10,
}
SlashDebounce = false

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

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Radius)
	local NegativeRegion = (Handle.Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Handle.Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = GetParts(Region, 500, IgnoreList)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
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
	if not RightGrip then
		return
	end
	if RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle then
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
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
end

function Attack()
	local anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
		Parent = Tool,
	}
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function DashIt()
	local PlayersNearby = GetPlayersNearby(MaxDistance)
	local ClosestPlayer = {Player = nil, Position = nil, Distance = MaxDistance}
	for i, v in pairs(PlayersNearby) do
		local character = v.Parent
		if character then
			local torso = character:FindFirstChild("Torso")
			if torso then
				local DistanceApart = (Handle.Position - torso.Position).Magnitude
				if DistanceApart < ClosestPlayer.Distance then
					ClosestPlayer.Player = character
					ClosestPlayer.Position = torso.Position
					ClosestPlayer.Distance = DistanceApart
				end
			end
		end
	end
	if not ClosestPlayer.Player then
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			MousePosition = MousePosition.Position
			ClosestPlayer.Player = Character
			ClosestPlayer.Position = MousePosition
		end
	end
	local TorsoPosition = Torso.Position
	local Direction = (CFrame.new(Handle.Position, ClosestPlayer.Position).lookVector * Vector3.new(1, 0, 1))
	DashGyro = Create("BodyGyro"){
		P = 30000,
		maxTorque = Vector3.new(30000, 30000, 30000),
		cframe = (CFrame.new(TorsoPosition, (ClosestPlayer.Position * Vector3.new(1, 0, 1) + Vector3.new(0, TorsoPosition.Y, 0))) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		Parent = Torso,
	}
	DashPosition = Create("BodyPosition"){
		P = 100000,
		maxForce = Vector3.new(100000, 100000, 100000),
		position = (TorsoPosition + Vector3.new(0, 1.5, 0)),
		Parent = Torso,
	}
	DashAngularVelocity = Create("BodyAngularVelocity"){
		P = 100000,
		maxTorque = Vector3.new(100000, 100000, 100000),
	}
	DashVelocity = Create("BodyVelocity"){
		P = 100000,
		maxForce = Vector3.new(100000, 0, 100000),
		velocity = (Direction * 64),
	}
	
	for i, v in pairs({DashGyro, DashPosition, DashAngularVelocity, DashVelocity}) do
		Debris:AddItem(v, 1.75)
	end
	
	DashGyro.Parent = Torso
	DashPosition.Parent = Torso
	
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Dash)
	end)
	
	wait(0.5)
	
	Sounds.Spin:Play()
	
	DashGyro.maxTorque = Vector3.new(DashPosition.P, 0, DashPosition.P)
	DashPosition.maxForce = Vector3.new(0, DashPosition.P, 0)
	DashVelocity.Parent = Torso
	DashAngularVelocity.angularvelocity = Torso.CFrame:vectorToWorldSpace(Vector3.new(0, -30, 0))
	Humanoid.Sit = true
	DashAngularVelocity.Parent = Torso

	wait(1)

	Humanoid.Sit = false
	
	for i, v in pairs({DashPosition, DashAngularVelocity, DashVelocity}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	
	DashGyro.cframe = (CFrame.new(TorsoPosition, (ClosestPlayer.Position * Vector3.new(1, 0, 1) + Vector3.new(0, TorsoPosition.Y, 0))))
	DashGyro.maxTorque = Vector3.new(DashGyro.P, DashGyro.P, DashGyro.P)
	Sounds.Spin:Stop()
	wait(0.25)
end

function SlashIt()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Slash)
	end)
	local PlayersNearby = GetPlayersNearby(MaxDistance)
	local ClosestPlayer = {Player = nil, Position = nil, Distance = MaxDistance}
	for i, v in pairs(PlayersNearby) do
		local character = v.Parent
		if character then
			local torso = character:FindFirstChild("Torso")
			if torso then
				local DistanceApart = (Handle.Position - torso.Position).Magnitude
				if DistanceApart < ClosestPlayer.Distance then
					ClosestPlayer.Player = character
					ClosestPlayer.Position = torso.Position
					ClosestPlayer.Distance = DistanceApart
				end
			end
		end
	end
	if not ClosestPlayer.Player then
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			MousePosition = MousePosition.Position
			ClosestPlayer.Player = Character
			ClosestPlayer.Position = MousePosition
		end
	end
	local Direction = (CFrame.new(Handle.Position, ClosestPlayer.Position).lookVector * Vector3.new(1, 0, 1))
	SlashVelocity = Create("BodyVelocity"){
		P = 100000,
		maxForce = Vector3.new(100000, 0, 100000),
		velocity = (Direction * 50),
	}
	Debris:AddItem(SlashVelocity, 0.5)
	SlashVelocity.Parent = Torso
	Torso.CFrame = (CFrame.new(Torso.Position, (ClosestPlayer.Position * Vector3.new(1, 0, 1) + Vector3.new(0, Torso.Position.Y, 0))))
	wait(0.5)
	Sounds.Slash:Play()
	wait(0.5)
end

function BlowIt(Explosions)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.DualSlash)
	end)
	wait(0.75)
	local Position = Handle.Position
	local Direction = Torso.CFrame.lookVector
	Sounds.LineExplosion:Play()
	local PlayersHit = {}
	local Pressure = 50
	for i = 2, Explosions, 1 do
		local Explosion = Create("Explosion"){
			ExplosionType = Enum.ExplosionType.Craters,
			BlastRadius = 10,
			BlastPressure = 0,
			Position = (Position + (Direction * (i * 10))),
		}
		Explosion.Hit:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				if not character.Parent then
					return
				end
				character = character.Parent
			end
			if CheckTableForInstance(PlayersHit, character) then
				return
			end
			local humanoid = nil
			for ii, v in pairs(character:GetChildren()) do
				if v:IsA("Humanoid") then
					humanoid = v
					break
				end
			end
			if humanoid and humanoid.Health > 0 then
				for ii, v in pairs(character:GetChildren()) do
					if v:IsA("ForceField") then
						return
					end
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player and (player == Player or IsTeamMate(Player, player)) then
					return
				end
				table.insert(PlayersHit, character)
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damages.Explosion)
			elseif not Hit.Anchored then
				print("B", Hit)
				Hit:BreakJoints()
				Hit.Velocity = (CFrame.new(Explosion.Position, Hit.Position).lookVector * Pressure)
			end
		end)
		Explosion.Parent = game:GetService("Workspace")
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Time = tick()
	if (Time - LastSuperStrike) < 0.2 and Balefire.Enabled then
		Balefire.Enabled = false
		BlowIt(10)
		Delay(Balefire.ReloadTime, (function()
			Balefire.Enabled = true
		end))
		wait(0.5)
	elseif (Time - DashTime) < 0.2 then
		DashIt()
		wait(0.5)
	elseif (Time - LastSlash) < 0.2 then
		SlashIt()
	elseif not SlashDebounce then
		SlashDebounce = true
		Sounds.Whack:Play()
		LastSlash = Time
		Damage = Damages.Slash
		Attack()
		Damage = Damages.Touch
		Delay(0.5, (function()
			SlashDebounce = false
		end))
	end
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
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.SwordPumpUp)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({SlashVelocity, DashGyro, DashPosition, DashAngularVelocity, DashVelocity}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
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
	if Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Down then
			local Time = tick()
			if Key == "w" then
				if (Time - LastDown.W) < 0.2 then
					DashTime = Time
				end
				LastDown.W = Time
			elseif Key == "a" then
				LastDown.A = Time
			elseif Key == "d" then
				LastDown.D = Time
				if (LastDown.D - LastDown.A) < 0.4 and LastDown.W > LastDown.A then 
					LastSuperStrike = Time
				end
			end
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)