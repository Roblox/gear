--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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


HitScript = script:WaitForChild("HitScript")

Sparks = script:WaitForChild("Sparks")

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Up = CFrame.new(0, -0.2, 0.9, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, -0.2, 0.9, 1, 0, -0, 0, 1, 0.15, 0, -0.15, 1),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.SmoothNoOutlines,
	BottomSurface = Enum.SurfaceType.SmoothNoOutlines,
	FrontSurface = Enum.SurfaceType.SmoothNoOutlines,
	BackSurface = Enum.SurfaceType.SmoothNoOutlines,
	LeftSurface = Enum.SurfaceType.SmoothNoOutlines,
	RightSurface = Enum.SurfaceType.SmoothNoOutlines,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseSnowball = BasePart:Clone()
BaseSnowball.Name = "Projectile"
BaseSnowball.BrickColor = BrickColor.new("Institutional white")
BaseSnowball.Material = Enum.Material.Concrete
BaseSnowball.Shape = Enum.PartType.Block
BaseSnowball.Size = Vector3.new(0.75, 0.75, 0.75)
BaseSnowball.CanCollide = true
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.Sphere,
	MeshId = "",
	TextureId = "",
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseSnowball,
}

Gravity = 196.20

Force = 110
Damage = 8
FireRate = 0.5

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
	local Snowball = BaseSnowball:Clone()
	local Mass = (Snowball:GetMass() * Gravity)
	local Direction = CFrame.new(StartPos, TargetPos)
	local Orientation = (Direction * CFrame.Angles((math.pi / 2), 0, 0))
	local Velocity = (Direction.lookVector * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new((Mass * 0.65), (Mass * 0.85), (Mass * 0.65)),
		velocity = Velocity,
		Parent = Snowball,
	}
	Snowball.Velocity = Velocity
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Orientation
	}
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = Damage},
	}
	local SparksCopy = Sparks:Clone()
	SparksCopy.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
	SparksCopy.Enabled = true
	SparksCopy.Parent = Snowball
	local HitScriptCopy = HitScript:Clone()
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = HitScriptCopy,
		}
	end
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = Snowball
	Debris:AddItem(Snowball, 5)
	Snowball.Parent = game:GetService("Workspace")
	Snowball.CFrame = (Orientation + Direction.lookVector * ((Handle.Size.Z / 2) + (Snowball.Size.Y / 2)))
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
	Sounds.Fire:Play()
	local StartPosition = (Handle.CFrame * CFrame.new(0, (Handle.Size.Y / 2), -(Handle.Size.Z + (BaseSnowball.Size.Z / 2)))).p
	local TargetPosition = MousePosition.Position
	Tool.Grip = Grips.Out	Fire(StartPosition, TargetPosition)
	wait(FireRate)
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