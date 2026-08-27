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


Functions = require(script:WaitForChild("Functions"))

LaserModelRemoval = script:WaitForChild("LaserModelRemoval")

Animations = {
	Pose = {Animation = Tool:WaitForChild("Pose"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	LaserSound = Handle:WaitForChild("LaserSound"),
}

Damage = 5
ReloadTime = 0.1
NeckChangedConnections = {}

PartName = "Glasses"

FireRate = 0.1
LaserRange = 50
LaserOffset = 1

MouseDown = false
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

function CastLaser(StartPosition, Direction, MaxDistance, Ignore, Color)
	local LaserModelName = (Player.Name .. "_LaserModel")
	local LaserModel = game:GetService("Workspace"):FindFirstChild(LaserModelName)
	if not LaserModel then
		LaserModel = Create("Model"){
			Name = LaserModelName,
		}
		local LaserModelRemovalClone = LaserModelRemoval:Clone()
		LaserModelRemovalClone.Disabled = false
		LaserModelRemovalClone.Parent = LaserModel
		LaserModel.Parent = game:GetService("Workspace")
	end
	table.insert(Ignore, LaserModel)
	local Hit, EndPosition, Normal = Functions.CastRay(StartPosition, Direction, MaxDistance, Ignore, false)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Create("Part"){
		Name = "Laser",
		BrickColor = BrickColor.new(Color),
		Transparency = 0.5,
		Shape = Enum.PartType.Block,
		FormFactor = Enum.FormFactor.Custom,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Anchored = true,
		Locked = true,
		Size = Vector3.new(0.2, Distance, 0.2),
		Create("CylinderMesh"){
			VertexColor = Vector3.new(1, 1, 1),
			Scale = Vector3.new(1, 1, 1),
		}
	}
	for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
		local Light = Create("SurfaceLight"){
			Brightness = 100,
			Range = 4,
			Angle = 90,
			Color = BrickColor.new(Color).Color,
			Face = Enum.NormalId[v],
			Shadows = false,
			Enabled = true,
			Parent = LaserPart,
		}
	end
	Debris:AddItem(LaserPart, 1)
	LaserPart.Parent = LaserModel

	LaserPart.CFrame = ((CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))) * CFrame.Angles((math.pi / 2), 0, 0))
	Spawn(function()
		InvokeClient("SetMouse", {Property = "TargetFilter", Value = game:GetService("Workspace"):FindFirstChild(LaserModelName)})
	end)
	Spawn(function()
		for i = 1, 20 do
			wait(0.05)
			LaserPart.Transparency = (LaserPart.Transparency + 0.05)
		end
	end)
	return Hit, EndPosition
end

function StopLaser()
	Sounds.LaserSound:Stop()
	MouseDown = false
	if Neck and Neck.Parent then
		Neck.C1 = NeckOrigin
	end
end

function FireLaser(Mouse)
	IgnoreHeadChange = true
	local LastHeadRotation = Neck.C1
	Neck.C1 = NeckOrigin
	local HeadOrigin = Head:Clone()
	local Base = Neck.Part0.Position + (Neck.C0.p * 1)
	local YVector = (Mouse.Hit.p + Mouse.Hit.lookVector)
	local Set = CFrame.new(Base, YVector)
	local Offset = Set:toObjectSpace(Torso.CFrame * Neck.C0)
	local PosX, PosY, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Offset:components()
	Neck.C1 = CFrame.new(NeckOrigin.p.x, NeckOrigin.p.y, NeckOrigin.p.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	local HeadRotationCheck = false
	if math.abs((Head.Position - Torso.Position).magnitude) >= 1.25 then
		HeadRotationCheck = true
	else
		Neck.C1 = LastHeadRotation
	end
	IgnoreHeadChange = false
	if HeadRotationCheck and (math.acos((Mouse.Hit.p - HeadOrigin.Position).Unit:Dot(HeadOrigin.CFrame.lookVector)) <= (math.pi / 2)) then
		for i, v in pairs(NeckChangedConnections) do
			v:disconnect()
		end
		NeckChangedConnections = {}
		Spawn(function()
			Tool.Enabled = false
			Sounds.LaserSound:Play()
			local NewLaserOffset = (LaserOffset * 100)
			local TargetPoint = (Mouse.Hit.p + Vector3.new((math.random(-NewLaserOffset, NewLaserOffset) * 0.01), (math.random(-NewLaserOffset, NewLaserOffset) * 0.01), (math.random(-NewLaserOffset, NewLaserOffset) * 0.01)))
			for i = 1, 2 do
				local SpawnPos = (Glasses.CFrame * CFrame.new((0.35 * ((i == 1 and 1) or -1)), -0.1, -0.375))
				local Hit, EndPosition = CastLaser(SpawnPos.p, (TargetPoint - SpawnPos.p).Unit, LaserRange, {Character}, "Really red")
				if Hit and Hit.Parent then
					local character = Hit.Parent
					if character:IsA("Hat") then
						character = character.Parent
					end
					if character and character ~= Character then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 then
							local player = Players:GetPlayerFromCharacter(character)
							if (not player or (player and not Functions.IsTeamMate(Player, player))) then
								Functions.UntagHumanoid(humanoid)
								Functions.TagHumanoid(humanoid, Player)
								humanoid:TakeDamage(Damage)
							end
						end
					end
				end
			end
			wait(ReloadTime)
			Tool.Enabled = true
		end)
		local NeckChanged
		NeckChanged = Neck.Changed:connect(function(Property)
			if Property == "C0" or Property == "C1" and not IgnoreHeadChange then
				for i, v in pairs(NeckChangedConnections) do
					v:disconnect()
				end
				NeckChangedConnections = {}
			end
		end)
		table.insert(NeckChangedConnections, NeckChanged)
		Delay(1, function()
			if NeckChanged.connected then
				Neck.C1 = NeckOrigin
				StopLaser()
			end
		end)
	else
		IgnoreHeadChange = true
		Neck.C1 = LastHeadRotation
		IgnoreHeadChange = false
	end
end

function CreateGlasses(CreateNew)
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name == PartName then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
	if not CreateNew then
		return
	end
	Handle.Transparency = 1
	Glasses = Handle:Clone()
	Glasses.Name = PartName
	Glasses.Transparency = 0
	Glasses.CanCollide = false
	local GlassesWeld = Create("Weld"){
		Part0 = Head,
		Part1 = Glasses,
		C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
		C1 = ((Tool.Grip + Vector3.new(-1.5, 0, 1.5)) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		Parent = Glasses,
	}
	Glasses.Parent = Character
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or MouseDown then
		return
	end
	MouseDown = true
	Spawn(function()
		while ToolEquipped and MouseDown and CheckIfAlive() do
			Sounds.LaserSound.Volume = (((math.sin(tick() * 3) + 1) * 0.25) + 0.25)
			Spawn(function()
				local MouseData = InvokeClient("MousePosition")
				if MouseData then
					FireLaser(MouseData)
				end
			end)
			wait(FireRate)
		end
		Sounds.LaserSound:Stop()
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Neck and Neck.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	Neck = Torso:FindFirstChild("Neck")
	NeckOrigin = Neck.C1
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Pose)
	end)
	Spawn(function()
		CreateGlasses(true)
	end)
	MouseDown = false
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
	StopLaser()
	CreateGlasses(false)
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if not Down then
			MouseDown = false
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