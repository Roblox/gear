--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Fire = Handle:WaitForChild("Fire")

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


DeathEffect = script:WaitForChild("DeathEffect")

DamageValues = {
	BaseDamage = 14,
	SlashDamage = 20,
	LungeDamage = 26,
}

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

Special = {
	Active = false,
	Enabled = true,
	Duration = 15,
	CoolDown = 10,
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 0.7, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.75},
	Explode = {Animation = Tool:WaitForChild("Explode"), FadeTime = 0.25, Weight = nil, Speed = 2, Duration = 0.75},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Grips = {
	Up = CFrame.new(0, -1.85, 0.05, 1, 0, -0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -1.85, 0.05, 1, 0, 0, 0, 0, -1, -0, 1, 0),
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
Fire.Enabled = false
Tool.Grip = Grips.Up
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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
		local PossibleParts = GetTotalParts(MaxParts, 3000, #Parts)
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
	local rootpart = character:FindFirstChild("HumanoidRootPart")
	if not rootpart then
		rootpart = character:FindFirstChild("Torso")
	end
	if not humanoid or humanoid.Health == 0 or not rootpart then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
	if humanoid.Health <= 0 then
		local WindDir = (CFrame.new(RootPart.Position, Vector3.new(rootpart.Position.X, RootPart.Position.Y, rootpart.Position.Z)) * CFrame.Angles(0, math.pi, 0)).lookVector
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
		if character == Character or (Special.Active and RandomNearby and character ~= RandomNearby.Character) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local rootpart = character:FindFirstChild("HumanoidRootPart")
		if not rootpart then
			rootpart = character:FindFirstChild("Torso")
		end
		if not humanoid or humanoid.Health == 0 or not rootpart then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		HitDelay = true
		local TotalDamage = (Damage * ((Special.Active and math.huge) or 1))
		DealDamage(character, TotalDamage)
		wait(0.05)
		HitDelay = false
	end)
end

function PossessedAttack()
	Fire.Enabled = true
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local SpecialStart = tick()
	while ToolEquipped and CurrentlyEquipped and CheckIfAlive() and (tick() - SpecialStart) < Special.Duration do
		local UserPlayer = Player
		local UserCharacter = Character
		local IgnoreObjects = {UserCharacter, Tool}
		local Radius = 35
		local Objects = {}
		local Humanoids = {}
		local PlayersNearby = {}
		local NegativeRadius = (RootPart.Position - Vector3.new(Radius, (RootPart.Size.Y * 1.25), Radius))
		local PositiveRadius = (RootPart.Position + Vector3.new(Radius, (Radius / 6), Radius))
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= UserPlayer then
				local character = v.Character
				if character and character.Parent then
					table.insert(IgnoreObjects, v)
					if not IsTeamMate(v, UserPlayer) then
						local humanoid = character:FindFirstChild("Humanoid")
						local rootpart = character:FindFirstChild("HumanoidRootPart")
						if not rootpart then
							rootpart = character:FindFirstChild("Torso")
						end
						if humanoid and humanoid.Health > 0 and (RootPart.Position - rootpart.Position).magnitude <= Radius then
							table.insert(Humanoids, humanoid)
						end
					end
				end
			end
		end
		if #Humanoids == 0 then
			local Parts = GetParts(Region3.new(NegativeRadius, PositiveRadius), 500, IgnoreObjects)
			for i, v in pairs(Parts) do
				if v and v.Parent and not CheckTableForInstance(Objects, v) then
					local character = v.Parent
					if character:IsA("Hat") or character:IsA("Tool") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					local player = Players:GetPlayerFromCharacter(character)
					if not CheckTableForInstance(Humanoids, humanoid) and not CheckTableForInstance(PlayersNearby, character) then
						if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
							table.insert(Humanoids, humanoid)
							if player and not CheckTableForInstance(PlayersNearby, player) then
								table.insert(PlayersNearby, player)
							end
						elseif (RootPart.Position - v.Position).magnitude <= Radius then
							table.insert(Objects, v)
						end
					end
				end
			end
		end
		local NearPlayers = {}
		for i, v in pairs(Humanoids) do
			local character = v.Parent
			local player = Players:GetPlayerFromCharacter(character)
			local rootpart = character:FindFirstChild("HumanoidRootPart")
			if not rootpart then
				rootpart = character:FindFirstChild("Torso")
			end
			if rootpart then
				table.insert(NearPlayers, {Character = character, Humanoid = v, RootPart = rootpart, Distance = (RootPart.Position - rootpart.Position).Magnitude})
			end
		end
		table.sort(NearPlayers, (function(a, b)
			return a.Distance < b.Distance
		end))
		if #NearPlayers > 0 then
			local MaxNearbyCount = 3
			local MaxNearby = ((#NearPlayers <= MaxNearbyCount and #NearPlayers) or MaxNearbyCount)
			RandomNearby = NearPlayers[math.random(1, MaxNearby)]
			local OrigPos = RootPart.CFrame
			local NewPos = (RandomNearby.RootPart.CFrame * CFrame.new(0, ((RootPart.Size.Z / 2) + (RandomNearby.RootPart.Size.Z / 2) + (RootPart.Size.Y / 2)), ((RootPart.Size.Z / 2) + (RandomNearby.RootPart.Size.Z / 2) + 0.75)))
			RootPart.CFrame = CFrame.new(NewPos.p, RandomNearby.RootPart.CFrame.p)
			RootPart.Anchored = true
			Attack()
			wait(1)
			RootPart.CFrame = OrigPos
			RootPart.Anchored = false
			wait(1.5)
		end
		wait()
	end
	Fire.Enabled = false
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
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or Special.Active then
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

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
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
		Humanoid.WalkSpeed = (16 * 1.5)
	end)
end

function Unequipped()
	Humanoid.WalkSpeed = 16
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPressed" then
		local Key = string.lower(value.Key)
		local Down = value.Down
		if Key == "q" and Down then
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			PossessedAttack()
			Special.Active = false
			wait(Special.CoolDown)
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)