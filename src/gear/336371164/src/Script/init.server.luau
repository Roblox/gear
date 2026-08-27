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

ProjectileScript = script:WaitForChild("ProjectileScript")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
	Reload = Handle:WaitForChild("Reload"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.BrickColor = BrickColor.new("Pastel Blue")
BaseProjectile.Transparency = 0.375
BaseProjectile.Material = Enum.Material.Neon
BaseProjectile.Size = Vector3.new(0.25, 2, 0.25)
BaseProjectile.CanCollide = false
for i, v in pairs({"Left", "Right", "Top", "Bottom", "Front", "Back"}) do
	BaseProjectile[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
end
Create("CylinderMesh"){
	Scale = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseProjectile,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ReloadTime = 2
ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled or not MouseData or not MouseData.Position then
		return
	end
	Tool.Enabled = false
	Sounds.Fire:Play()
	local StartPosition = (Handle.CFrame * CFrame.new(0, 0.25, -((Handle.Size.Z / 2) + (BaseProjectile.Size.Z / 2) + 2)))
	local TargetPosition = MouseData.Position
	local Projectile = BaseProjectile:Clone()
	local ProjectileOrientation = CFrame.new(StartPosition.p, TargetPosition)
	local Force = 75
	local Gravity = 196.20
	local Mass = (Projectile:GetMass() * Gravity)
	local Velocity = (ProjectileOrientation.lookVector * Force)
	local Force = Create("BodyVelocity"){
		Name = "BodyVelocity",
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Projectile,
	}
	Projectile.Velocity = Velocity
	Projectile.CFrame = (ProjectileOrientation * CFrame.Angles((math.pi / 2), 0, 0))
	local ProjectileScriptCopy = ProjectileScript:Clone()
	local Values = {
		{Name = "Creator", Value = Player, Class = "ObjectValue"},
		{Name = "Tool", Value = Tool, Class = "ObjectValue"},
	}
	for i, v in pairs(Values) do
		local Creator = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile,
		}
	end
	local HitSound = Sounds.Hit:Clone()
	HitSound.Parent = Projectile
	ProjectileScriptCopy.Disabled = false
	ProjectileScriptCopy.Parent = Projectile
	Debris:AddItem(Projectile, 3)
	Projectile.Parent = game:GetService("Workspace")
	wait(ReloadTime / 2)
	Sounds.Reload:Play()
	wait(ReloadTime / 2)
	Tool.Enabled = true
end

function Equipped()
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

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)