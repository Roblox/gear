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

Gravity = workspace.Gravity

HammerStrength = 30
UpStrength = 1500
ReloadTime = 5

Forces = {}

Animations = {
	GravitySlam = {Animation = Tool:WaitForChild("GravitySlam"), FadeTime = 0.1, Weight = 1, Speed = 1, Duration = 0.75},
	StaffOut = {Animation = Tool:WaitForChild("StaffOut"), FadeTime = 0.1, Weight = 1, Speed = 0.75, Duration = nil},
	R15GravitySlam = {Animation = Tool:WaitForChild("R15GravitySlam"), FadeTime = 0.1, Weight = 1, Speed = 1, Duration = 0.75},
	R15StaffOut = {Animation = Tool:WaitForChild("R15StaffOut"), FadeTime = 0.1, Weight = 1, Speed = 0.75, Duration = nil}	
}

Sounds = {
	InitialHit = Handle:WaitForChild("InitialHit"),
	Hit = Handle:WaitForChild("Hit"),
	SendOut = Handle:WaitForChild("SendOut"),
}

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetObjectsNearby(Radius)
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
	return Parts
end 

function MakeFire()
	local FirePart = BasePart:Clone()
	FirePart.Name = "FirePart"
	FirePart.Transparency = 1
	local Fire = Create("Fire"){
		Color = Color3.new((85 / 255), (255 / 255), (255 / 255)),
		SecondaryColor = Color3.new((180 / 255), (255 / 255), (255 / 255)),
		Heat = -5,
		Size = 8,
		Parent = FirePart,
	}
	local Weld = Create("Weld"){
		Part0 = FirePart,
		Part1 = Handle,
		C0 = CFrame.new(0, -4.5, 0),
		Parent = FirePart,
	}
	Debris:AddItem(FirePart, 1.5)
	FirePart.Parent = Tool
end

function ExpandFire()
	if not CheckIfAlive() then
		return
	end
	local Fire = Create("Fire"){
		Color = Color3.new((85 / 255), (255 / 255), (255 / 255)),
		SecondaryColor = Color3.new((180 / 255), (255 / 255), (255 / 255)),
		Heat = -5,
		Size = 1,
	}
	local HeatRate = 8
	local HeatDelay = 0.2
	Debris:AddItem(Fire, (HeatRate * HeatDelay))
	Fire.Parent = Torso
	for i = 1, HeatRate do
		Fire.Size = (Fire.Size + 4)
		wait(HeatDelay)
	end
end

function AddPart(Object, Recursive, Table)
	if Object.Anchored and not CheckTableForInstance(Table, Object) then
		return {}
	end
	local Objects = {Object}
	local DistanceApart = (Handle.Position - Object.Position).Magnitude
	local Height = (HammerStrength * (1 - (DistanceApart / HammerStrength)))
	local Mass = (Object:GetMass() * UpStrength)
	local BodyPosition = Create("BodyPosition"){
		position = Object.Position + Vector3.new(0, Height, 0),
		P = Mass,
		D = (Mass / 2),
		maxForce = Vector3.new(Mass, Mass, Mass),
	}
	table.insert(Forces, BodyPosition)
	Debris:AddItem(BodyPosition, 3)
	BodyPosition.Parent = Object
	local humanoid
	if Object.Parent then
		for i, v in pairs(Object.Parent:GetChildren()) do
			if v:IsA("Humanoid") then
				humanoid = v
			end
		end
		if not humanoid and not Object.Parent:IsA("Hat") and not Object.Parent:IsA("Tool") then
			Object:BreakJoints()
		elseif humanoid and Recursive then
			local parts = GetAllConnectedParts(Object)
			for i, v in pairs(parts) do
				if not CheckTableForInstance(Table, v) and not CheckTableForInstance(Objects, v) then
					for ii, vv in pairs(AddPart(v, false, Table)) do
						if not CheckTableForInstance(Table, vv) and CheckTableForInstance(Objects, vv) then
							table.insert(Objects, v)
						end
					end
				end
			end
		end
	end
	return Objects
end

function PickUpNearbyParts(Parts)
	local PartsAffected = {}
	for i, v in pairs(Parts) do
		for ii, vv in pairs(AddPart(v, true, PartsAffected)) do
			table.insert(PartsAffected, vv)
		end
	end
	AddPart(Torso, true, {})
	return PartsAffected
end

function SendOut(Objects)
	if #Objects <= 0 then
		return
	end
	Spawn(function()
		local Animation = Animations.StaffOut
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15StaffOut
		end
		InvokeClient("PlayAnimation", Animation)
	end)
	Sounds.SendOut:Play()
	Spawn(ExpandFire)
	wait(0.3)
	for i, v in pairs(Objects) do
		local Direction = CFrame.new(Handle.Position, v.Position)
		local BodyForce = Create("BodyForce"){
			force = (Direction.lookVector * v:GetMass() * 400),
		}
		Debris:AddItem(BodyForce, 1)
		BodyForce.Parent = v
		if v.Parent then
			for ii, vv in pairs(v.Parent:GetChildren()) do
				if vv:IsA("Humanoid") then
					vv.Sit = true
				end
			end
		end
	end
	wait(0.75)
	Spawn(function()
		local Animation = Animations.StaffOut
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15StaffOut
		end
		InvokeClient("StopAnimation", Animation)
	end)
end

function SendFlying()
	for i, v in pairs(Forces) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Forces = {}
	MakeFire()
	local Animation = Animations.GravitySlam
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15GravitySlam
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	Sounds.InitialHit:Play()
	Sounds.Hit:Play()
	if not CurrentlyEquipped then
		return
	end
	local Parts = GetObjectsNearby(HammerStrength)
	local Objects = PickUpNearbyParts(Parts)
	wait(2)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	SendOut(Objects)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	SendFlying()
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	for i, v in pairs(Forces) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Forces = {}
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)