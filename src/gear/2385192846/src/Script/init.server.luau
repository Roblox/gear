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


BaseUrl = "rbxassetid://"

local sandwich = Tool.DisplayModel.Sandwich:Clone()

local Lunchbox = require(script.Lunchbox)

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = 0.5, Weight = nil, Speed = 2, Duration = (2 / 2)},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = 0.5, Weight = nil, Speed = 2, Duration = (2 / 2)}
}

Grips = {}

Sounds = {}

ReloadTime = 5

InView = false
ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
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

function ThrowBriefcase(TargetPosition)
	if not TargetPosition then
		return
	end
	local Briefcase = Create("Model"){
		Name = "Lunchbox",
	}
	local Lid = BasePart:Clone()
	Lid.Name = "Lid"
	Lid.Size = Vector3.new(0.375, 1.475, 2.4)
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "2380506739"),
		TextureId = (BaseUrl .. "2380507786"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Lid
	}
	local Bottom = BasePart:Clone()
	Bottom.Name = "Bottom"
	Bottom.Size = Vector3.new(0.5, 1.975, 2.4)
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "2380507495"),
		TextureId = (BaseUrl .. "2380507786"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Bottom
	}
	--[[local Weld = Create("Weld"){
		Part0 = Handle,
		Part1 = Bottom,
		C0 = CFrame.new(-0.075000003, 0, 0.0250000004, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Parent = Bottom,
	}]]
	local Motor = Create("Motor6D"){
		Name = "Hinge",
		Part0 = Lid,
		Part1 = Bottom,
		C0 = CFrame.new(0.00993475318, -0.742155671, 9.01495878e-06, 0.707096636, 0.707111061, -3.97479744e-06, -0.707112193, 0.707092583, 2.18266723e-05, 1.55199832e-05, -1.57631057e-05, 0.999999464),
		C1 = CFrame.new(-0.300000012, -1, 0, 0.642787516, 0.766044557, 0, -0.766044557, 0.642787516, 0, 0, 0, 1),
		DesiredAngle = 0,
		CurrentAngle = 0,
		MaxVelocity = 0.1,
		Parent = Bottom,
	}
	for i, v in pairs({Lid, Bottom}) do
		v.Friction = 2
		v.Elasticity = 0
		v.Parent = Briefcase
	end
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Briefcase,
		}
	end
--	local BriefcaseScriptCopy = BriefcaseScript:Clone()
--	BriefcaseScriptCopy.Disabled = false
--	BriefcaseScriptCopy.Parent = Briefcase
	Lunchbox:Throw(Briefcase, sandwich)
	Bottom.CFrame = Handle.CFrame
	Debris:AddItem(Briefcase, 8)
	Briefcase.Parent = workspace
	
	local MaxDistance = 50
	local StartPosition = Handle.Position
	local Direction = CFrame.new(StartPosition, Vector3.new(TargetPosition.X, StartPosition.Y, TargetPosition.Z))
	local SpawnPosition = ((CFrame.new(StartPosition) * CFrame.Angles(Bottom.CFrame:toEulerAnglesXYZ())) + Direction.lookVector * Bottom.Size.Z * 2)
	local Distance = (StartPosition - TargetPosition).Magnitude
	if Distance > MaxDistance then
		TargetPosition = (SpawnPosition + Direction.lookVector * MaxDistance)
		Distance = MaxDistance
	end
	local Velocity = Distance	
	local ThrowVelocity = ((Direction.lookVector * Velocity) + Vector3.new(0, (Distance * 1), 0))
	--Bottom.CFrame = SpawnPosition
	Bottom.Velocity = ThrowVelocity
	Bottom.RotVelocity = Vector3.new((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01))
	
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	local MousePosition = MouseData.Position
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.Throw
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Throw
	end	
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration / 2)
	if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		Tool.Enabled = true
		return
	end
	Handle.Transparency = 1
	Spawn(function()
		ThrowBriefcase(MousePosition)
	end)
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
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
	ToolEquipped = true
end

function Unequipped()
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

ServerControl.OnServerInvoke = OnServerInvoke

Tool:GetPropertyChangedSignal("Parent"):Connect(function()
	Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((Tool.Enabled and 0) or 1)) or 0)
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)