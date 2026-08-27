--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

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

Gravity = 196.20
Rate = (1 / 60)

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

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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
	while CheckIfAlive() and ToolEquipped.Value and MouseDown.Value --[[and (tick() - StartTime) <= MaxDuration]] do
		StrikeCount = (StrikeCount + 1)
		if StrikeCount > 1 then
		end
		Sounds.Strike.Volume = (((math.sin(tick() * 3) + 1) * 0.25) + 0.25)
		local MousePosition = InvokeClient("MouseData")
		if MousePosition then
			MousePosition = MousePosition.Position
			LightningFunctions.RemoveLightning()
			local RayData = LightningFunctions.Zap({StartPosition = (Handle.CFrame * CFrame.new(0, (Handle.Size.Y / 2), 0)).p, TargetPosition = MousePosition, Character = Character, Color = "Cyan", Individual = false})
			if RayData then
				local RayHit = RayData.RayHit
				if RayHit then
					local character = RayHit.Parent
					if character == Character then
						return
					end
					if character:IsA("Accoutrement") then
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
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		ResetStuff()
	end)
	ToolEquipped.Value = true
end

function Unequipped()
	ResetStuff()
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