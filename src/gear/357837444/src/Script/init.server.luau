--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Sparks = Handle:WaitForChild("Sparks")
Fire = Handle:WaitForChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

LightningFunctions = require(script:WaitForChild("LightningFunctions"))

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

Gravity = workspace.Gravity
Rate = (1 / 60)

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Animations = {}

Sounds = {
	Lightning = Handle:WaitForChild("Lightning"),
	Lightning2 = Handle:WaitForChild("Lightning2"),
	Strike = Handle:WaitForChild("Strike"),
	Zap = Handle:WaitForChild("Zap"),	
}

InUse = Create("BoolValue"){
	Value = false,
}
MouseDown = Create("BoolValue"){
	Value = false,
}
ToolEquipped = Create("BoolValue"){
	Value = false,
}

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

function TakeDamage(humanoid, Damage)
	if not humanoid or not humanoid:IsA("Humanoid") or not Damage or not Player then
		return
	end
	local character = humanoid.Parent
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		if IsTeamMate(Player, player) then
			return
		end
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
end

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

function MakeCircle(Origin, Radius, Parts)
	local Circle = Create("Model"){
		Name = "Circle",
	}
	for i = 1, Parts do
		local Part = BasePart:Clone()
		Part.Name = "Effect"
		Part.Transparency = 1
		Part.Size = Vector3.new(6, 0.2, (Radius * 2))
		Part.Anchored = true
		Part.CanCollide = false
		Part.CFrame = (Origin * CFrame.Angles(0, ((math.pi * 2) / (Parts / i)), 0))
		Part.CFrame = (Part.CFrame + Part.CFrame.lookVector * (Radius * 0.5))
		Part.Parent = Circle
	end
	return Circle
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return GetParts(Region, 500, IgnoreList)
end

function CreateStaff(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	--Handle.Transparency = ((CreateNew and 1) or 0)
	if not CreateNew then
		return
	end
	GripPiece = BasePart:Clone()
	GripPiece.Name = "GripPiece"
	GripPiece.Transparency = 1
	GripPiece.CanCollide = false
	GripPiece.Size = Vector3.new(0.2, 0.2, 0.2)
	for i, v in pairs({Sparks, Fire}) do
		local Particle = v:Clone()
		Particle.Enabled = true
		Particle.Parent = GripPiece
	end
	local SparksCopy = Sparks:Clone()
	SparksCopy.Enabled = true
	SparksCopy.Parent = GripPiece
	local Joints = {
		{Class = "Weld", Parent = GripPiece, Properties = {Part0 = GripPiece, Part1 = Handle, C0 = CFrame.new(0, -2, 0), C1 = CFrame.new(0, 0, 0)}},
	}
	for i, v in pairs(Joints) do
		local Joint = Create(v.Class){}
		for ii, vv in pairs(v.Properties) do
			Joint[ii] = vv
		end
		Joint.Parent = v.Parent
	end
	for i, v in pairs({GripPiece}) do
		v.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped.Value or MouseDown.Value or not CheckIfAlive() or InUse.Value then
		return
	end
	Tool.Enabled = false
	MouseDown.Value = true
	local CurrentlyEquipped = true
	local CurrentlyDown = true
	local ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local MouseButtonUp = MouseDown.Changed:connect(function()
		if not MouseDown.Value then
			CurrentlyDown = false
		end
	end)
	InUse.Value = true
	Sounds.Lightning:Play()
	Delay(0.25, (function()
		for i, v in pairs({ToolUnequipped, MouseButtonUp}) do
			if v then
				v:disconnect()
			end
		end
		if CurrentlyEquipped and CurrentlyDown and CheckIfAlive() then
			Sounds.Strike:Play()
		end
	end))
	local MaxDuration = 5
	local StartTime = tick()
	local StrikeCount = 0
	local LightningDamage = 10
	local FireRate = 0.1
	local LightningReloadTime = 2
	while CheckIfAlive() and ToolEquipped.Value and MouseDown.Value and GripPiece.Parent --[[and (tick() - StartTime) <= MaxDuration]] do
		StrikeCount = (StrikeCount + 1)
		Sounds.Strike.Volume = (((math.sin(tick() * 3) + 1) * 0.25) + 0.25)
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			MousePosition = MousePosition.Position
			LightningFunctions.RemoveLightning()
			local RayData = LightningFunctions.Zap({StartPosition = GripPiece.Position, TargetPosition = MousePosition, Character = Character, Color = "Royal purple", Individual = false})
			if RayData then
				local RayHit = RayData.RayHit
				if RayHit then
					local character = RayHit.Parent
					if character == Character then
						return
					end
					if character:IsA("Accessory") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
						local player = Players:GetPlayerFromCharacter(character)
						if not player or (player and not IsTeamMate(Player, player)) then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(LightningDamage)
						end
					end
				end
				Spawn(function()
					InvokeClient("SetMouse", {Property = "TargetFilter", Value = RayData.LightningModel})
				end)
			end
		end
		wait(FireRate)
	end
	InUse.Value = false
	Sounds.Strike:Stop()
	if StrikeCount > 1 then
		wait(LightningReloadTime)
	else
		wait(LightningReloadTime / 4)
	end
	Tool.Enabled = true
end

function ResetStuff()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	for i, v in pairs({InUse, MouseDown}) do
		v.Value = false
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		EquipTick = tick()
		ResetStuff()
		CreateStaff(true)
	end)
	ToolEquipped.Value = true
end

function Unequipped()
	ResetStuff()
	CreateStaff(true)
	ToolEquipped.Value = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped.Value or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if not Down and MouseDown.Value then
			MouseDown.Value = false
		end
	elseif mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Down and Tool.Enabled and not InUse.Value then
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

Delay(0, (function()
	CreateStaff(true)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)