--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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

Sounds = {
	Pop = Handle:WaitForChild("Pop"),
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

BaseBalloon = BasePart:Clone()
BaseBalloon.Name = "Balloon"
BaseBalloon.Transparency = 0
BaseBalloon.Size = Vector3.new(1, 4.75, 1)
BaseBalloon.CanCollide = true
BaseBalloon.Anchored = false
SphereMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = "",
	TextureId = (BaseUrl .. "429370216"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseBalloon,
}

Bunch = {
	Red = {Id = 429369860, MeshOffset = Vector3.new(0, 0, 0), Offset = Vector3.new(-0.49, -0.125, -0.05)},
	Blue = {Id = 429369719, MeshOffset = Vector3.new(0, 0, 0.25), Offset = Vector3.new(0.265, 0.09875, -0.525)},
	Yellow = {Id = 429369973, MeshOffset = Vector3.new(0, 0, 0), Offset = Vector3.new(0.425, 0.125, -0.075)},
	Green = {Id = 429369791, MeshOffset = Vector3.new(0, 0, -0.75), Offset = Vector3.new(0, 0, 0)},
}

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function ReleaseBalloons()
	Handle.Transparency = 1
	for i, v in pairs(Bunch) do
		local Balloon = BaseBalloon:Clone()
		Balloon.Name = (i .. Balloon.Name)
		Balloon.Mesh.MeshId = (BaseUrl .. v.Id)
		Balloon.Mesh.Offset = v.MeshOffset
		local Gravity = 196.20
		local Weight = (Balloon:GetMass() * Gravity * 2)
		local SwayDirection = CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)
		local FloatDirection = ((CFrame.new(Handle.Position, Balloon.Position) * CFrame.Angles(0, math.pi, 0) * SwayDirection).lookVector * Vector3.new(1, 0, 1))
		--local FloatDirection = (CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)).lookVector
		local FloatAwaySpeed = (FloatDirection * (math.random(-1500, 2500) * 0.001))
		local FloatUpSpeed = (5 + (math.random(1000, 3000) * 0.001))
		FloatAwaySpeed = (FloatAwaySpeed + Vector3.new(0, FloatUpSpeed, 0))
		local BodyGyro = Create("BodyGyro"){
			Name = "BodyGyro",
			maxTorque = Vector3.new(Weight, 0, Weight),
			D = 500,
			P = 3000,
			CFrame = Balloon.CFrame,
			Parent = Balloon
		}
		local BodyVelocity = Create("BodyVelocity"){
			Name = "BodyVelocity",
			maxForce = Vector3.new(Weight, Weight, Weight),			
			velocity = FloatAwaySpeed,
			P = 1250,
			Parent = Balloon,
		}
		local PopSound = Sounds.Pop:Clone()
		PopSound.Pitch = (math.random(900, 1250) * 0.001)
		PopSound.PlayOnRemove = true
		PopSound.Parent = Balloon
		local RemovalTime = (20 + (math.random(0, 5000) * 0.001))
		Debris:AddItem(Balloon, RemovalTime)
		Balloon.CFrame = (Handle.CFrame * CFrame.new(v.Offset - v.MeshOffset))
		Balloon.Parent = game:GetService("Workspace")
	end
	wait(5)
	Handle.Transparency = 0
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	ReleaseBalloons()
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)