--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

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


Bubbles = script:WaitForChild("Bubbles")
ProjectileScript = script:WaitForChild("ProjectileScript")

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

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Size = Vector3.new(1.5, 1.5, 1.5)
BaseProjectile.BrickColor = BrickColor.new("Really black")
BaseProjectile.CanCollide = false
BaseProjectile.Anchored = false
BaseProjectileMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "405581886"),
	TextureId = (BaseUrl .. "405582028"),
	Scale = Vector3.new(3, 3, 3),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile,
}

Projectiles = {
	Vector3.new(0, 0, 0),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

Gravity = 196.20

ReloadTime = 1.5
Damage = 0

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

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	Tool.Enabled = false
	Sounds.Fire:Play()
	local MousePosition = MouseData.Position
	local CreatedProjectiles = {}
	for i, v in pairs(Projectiles) do
		local Offset = (Handle.CFrame * CFrame.new(v))
		local Direction = CFrame.new(Offset.p, MousePosition)
		local Orientation = (Direction * CFrame.Angles(math.pi, 0, (math.pi + math.rad(math.random(-1500, 6000) * 0.01))))
		local Projectile = BaseProjectile:Clone()
		local Particles = Bubbles:Clone()
		Particles.Enabled = true
		Particles.Parent = Projectile
		Projectile.CFrame = Orientation
		local Force = 100
		local Mass = (Projectile:GetMass() * Gravity)
		local Velocity = (Direction.lookVector * Force)
		local BodyVelocity = Create("BodyVelocity"){
			maxForce = Vector3.new(Mass, Mass, Mass),
			velocity = Velocity,
			Parent = Projectile,
		}
		local BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			cframe = Orientation,
			Parent = Projectile,
		}
		Projectile.Velocity = Velocity
		local RemovalTime = 8
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Damage", Class = "NumberValue", Value = Damage},
			{Name = "RemovalTime", Class = "NumberValue", Value = (RemovalTime - 3)},
		}
		for ii, vv in pairs(Values) do
			local Value = Create(vv.Class){
				Name = vv.Name,
				Value = vv.Value,
				Parent = Projectile,
			}
		end
		local ProjectileScriptCopy = ProjectileScript:Clone()
		ProjectileScriptCopy.Disabled = false
		ProjectileScriptCopy.Parent = Projectile
		Debris:AddItem(Projectile, RemovalTime)
		Projectile.Parent = game:GetService("Workspace")
	end
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)