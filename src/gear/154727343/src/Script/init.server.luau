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


ShockScript = script:WaitForChild("ShockScript")
LightningFunctions = require(script:WaitForChild("LightningFunctions"))

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Up = CFrame.new(-0.0625, 0.899999976, 0.125, -1, 0, -0, -0, -1, 0, 0, 0, 1),
	Out = CFrame.new(-0.0625, 0.899999976, 0.125, -1, 0, -0, -0, -0.992277861, 0.124034733, 0, 0.124034733, 0.992277861)
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

BaseBolt = BasePart:Clone()
BaseBolt.Name = "Projectile"
BaseBolt.Size = Vector3.new(0.25, 1, 0.25)
BaseBolt.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "153952259"),
	TextureId = (BaseUrl .. "153952234"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseBolt,
}

Gravity = 196.20

ReloadTime = 0.75
Damage = 20

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
Tool.Grip = Grips.Up
Tool.Enabled = true

function Fire(StartPos, TargetPos)
	local Bolt = BaseBolt:Clone()
	local Mass = (Bolt:GetMass() * Gravity)
	local Direction = CFrame.new(StartPos, TargetPos)
	local Orientation = (Direction * CFrame.Angles((math.pi / 2), 0, 0))
	local Force = 50
	local Velocity = (Direction.lookVector * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Bolt,
	}
	Bolt.Velocity = Velocity
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Orientation
	}
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = Damage},
	}
	local ShockScriptCopy = ShockScript:Clone()
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = ShockScriptCopy,
		}
	end
	ShockScriptCopy.Disabled = false
	ShockScriptCopy.Parent = Bolt
	Debris:AddItem(Bolt, 5)
	Bolt.Parent = game:GetService("Workspace")
	Bolt.CFrame = (Orientation + Direction.lookVector * ((Handle.Size.Z / 2) + (Bolt.Size.Y / 2)))
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		Tool.Enabled = true
		return
	end
	local StartPosition = (Handle.CFrame * CFrame.new(0, -((Handle.Size.Y / 2) + 0.2), -((Handle.Size.Z / 2) - 0.05))).p
	local TargetPosition = MousePosition.Position
	Tool.Grip = Grips.Out
	LightningFunctions.RemoveLightning()
	LightningFunctions.Zap({StartPosition = StartPosition, TargetPosition = TargetPosition, Character = Character, Color = "Cyan", Individual = false, Duration = 2, TimeToFade = 0.375, MaxRange = 2, SegmentLength = 0.25, Thickness = 0.5, Ignore = {Character}})
	Fire(StartPosition, TargetPosition)
	wait(ReloadTime)
	Tool.Grip = Grips.Up
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Up
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Up
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)