--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ConfusionScript = script:WaitForChild("ConfusionScript")

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

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Sounds = {
	WooshStart = Handle:WaitForChild("WooshStart"),
	WooshEnd = Handle:WaitForChild("WooshEnd"),
}

Duration = 8
CoolDown = 3

TransparentObjects = {}

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Radius)
	local NegativeRegion = (Torso.Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Torso.Position + Vector3.new(Radius, Radius, Radius))
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
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

function GetAllObjectsWithProperty(Parent, Property, Type)
	local Objects = {}
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			local PropertyExists = false
			pcall(function()
				local Property = v[Property]
				if type(Property) == Type then
					PropertyExists = true
				end
			end)
			if PropertyExists then
				table.insert(Objects, v)
			end
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

function GetTransparentObjects(Parent)
	local Objects = {}
	local IgnoreObjects = {"HumanoidRootPart"}
	for i, v in pairs(GetAllObjectsWithProperty(Parent, "Transparency", "number")) do
		table.insert(Objects, v)
	end
	for i, v in pairs(Objects) do
		if CheckTableForString(IgnoreObjects, v.Name) then
			table.remove(Objects, i)
		end
	end
	return Objects
end

function ResetTransparency(Object)
	local PartNames = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "UpperTorso", "LowerTorso", "LowerLeftLeg", "LowerRightLeg", "UpperLeftLeg", "UpperRightLeg", "RightHand", "LeftHand", "LowerLeftArm", "LowerRightArm", "UpperRightArm", "UpperLeftArm", "RightFoot", "LeftFoot"}
	if not Object then
		for i, v in pairs({DescendantAdded, DescendantRemoving}) do
			if v then
				v:disconnect()
			end
		end
		for i, v in pairs(TransparentObjects) do
			v.Object.Transparency = ((CheckTableForString(PartNames, v.Object.Name) and 0) or v.Transparency)
		end
		TransparentObjects = {}
	else
		local Objects = GetAllObjectsWithProperty(Object, "Transparency", "number")
		for i, v in pairs(TransparentObjects) do
			for ii, vv in pairs(Objects) do
				if v.Object == vv then
					v.Object.Transparency = ((CheckTableForString(PartNames, v.Object.Name) and 0) or v.Transparency)
					table.remove(TransparentObjects, i)
					break
				end
			end
		end
	end
end

function SetTransparency(Parent, Invisible, Delay)
	local Objects = {}
	if type(Parent) == "table" then
		Objects = Parent
	else
		for i, v in pairs(GetTransparentObjects(Parent)) do
			table.insert(Objects, {Object = v, Transparency = v.Transparency})
		end
	end
	if ToolUnequipped1 then
		ToolUnequipped1:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped1 = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		if Delay then
			local AllAltered = false
			while not AllAltered and ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
				local AllCurrentlyAltered = true
				for i, v in pairs(Objects) do
					if ((Invisible and v.Object.Transparency < 1) or (not Invisible and v.Object.Transparency > v.Transparency)) then
						v.Object.Transparency = (v.Object.Transparency + (0.1 * ((Invisible and 1) or -1)))
						AllCurrentlyAltered = false
					end
				end
				if AllCurrentlyAltered then
					AllAltered = true
				end
				wait()
			end
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end
		if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
			return
		end
		for i, v in pairs(Objects) do
			if Invisible then
				v.Object.Transparency = 1
			else
				ResetTransparency(v.Object)
			end
		end
	end)
	return Objects
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Character:FindFirstChild("Invisible") then
		return
	end
	Tool.Enabled = false
	Invisible = Create("BoolValue"){
		Name = "Invisible",
		Value = true,
	}
	Debris:AddItem(Invisible, (Duration + 2))
	Invisible.Parent = Character
	for i, v in pairs({ToolUnequipped2, DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	local CurrentlyEquipped = true
	ToolUnequipped2 = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Humanoid.WalkSpeed = 26
	Sounds.WooshStart:Play()
	TransparentObjects = SetTransparency(Character, true, true)
	DescendantAdded = Character.ChildAdded:connect(function(Child)
		local Objects = SetTransparency(Child, true, false)
		for i, v in pairs(Objects) do
			table.insert(TransparentObjects, v)
		end
	end)
	DescendantRemoving = Character.ChildRemoved:connect(function(Child)
		ResetTransparency(Child)
	end)
	wait(Duration)
	Sounds.WooshEnd:Play()
	for i, v in pairs({ToolUnequipped2, DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	if CurrentlyEquipped then
		if CheckIfAlive() then
			Humanoid.WalkSpeed = 16
		end
		SetTransparency(TransparentObjects, false, true)
		TransparentObjects = {}
		local PlayersNearby = GetPlayersNearby(15)
		for i, v in pairs(PlayersNearby) do
			local character = v.Parent
			if character then
				local ConfusionScriptCopy = ConfusionScript:Clone()
				ConfusionScriptCopy.Disabled = false
				ConfusionScriptCopy.Parent = character
			end
		end
	end
	wait(CoolDown)
	Tool.Enabled = true
end

function MakeCape(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	Cape = Handle:Clone()
	Cape.Name = "Cape"
	Cape.Transparency = 0
	local Weld = Create("Weld"){
		Part0 = Torso,
		Part1 = Cape,
		C0 = CFrame.new(0, -0.15, 0.4),
		Parent = Cape,
	}
	Handle.Transparency = 1
	Cape.Parent = Tool
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		MakeCape(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		for i, v in pairs(Sounds) do
			v:Stop()
		end
		for i, v in pairs({ToolUnequipped2, DescendantAdded, DescendantRemoving}) do
			if v then
				v:disconnect()
			end
		end
		if Invisible and Invisible.Parent then
			Invisible:Destroy()
		end
		if CheckIfAlive() then
			Humanoid.WalkSpeed = 16
		end
		Handle.Transparency = 0
		MakeCape(false)
		ResetTransparency()
		ToolEquipped = false
	end)
end

MakeCape(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)