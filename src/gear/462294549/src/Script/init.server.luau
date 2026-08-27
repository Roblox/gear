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


BaseUrl = "http://www.roblox.com/asset/?id="

ExplosionScript = script:WaitForChild("ExplosionScript")

Sounds = {
	Fuse = Handle:WaitForChild("Fuse"),
}

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

BaseFirework = Handle:Clone()
BaseFirework.Name = "Firework"
BaseFirework.Transparency = 0
BaseFirework.Locked = true
BaseFirework.CanCollide = true

Rate = (1 / 60)
Gravity = 196.20

ReloadTime = 5

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function FireFirework()
	Handle.Transparency = 1
	local Firework = BaseFirework:Clone()
	Firework.CFrame = Handle.CFrame
	local Force = 35
	local Mass = (Firework:GetMass() * Gravity)
	local Velocity = (Vector3.new(0, 1, 0) * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Firework,
	}
	local AngleX, AngleY, AngleZ = Handle.CFrame:toEulerAnglesXYZ()
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		cframe = CFrame.new(0, AngleY, 0),
		Parent = Firework,
	}
	Firework.Velocity = Velocity
	Debris:AddItem(Firework, (60 / 2))
	Firework.Parent = game:GetService("Workspace")
	return Firework
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Enabled = false
	Sounds.Fuse:Play()
	if CurrentlyEquipped then
		local Firework = FireFirework()
		local ExplosionScriptClone = ExplosionScript:Clone()
		ExplosionScriptClone.Disabled = false
		ExplosionScriptClone.Parent = Firework
		wait(ReloadTime)
		if CurrentlyEquipped then
			Handle.Transparency = 0
		end
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)