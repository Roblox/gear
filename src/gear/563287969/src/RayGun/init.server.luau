--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
ProjectileSparks = Handle:WaitForChild("ProjectileSparks")

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


ProjectileScript = script:WaitForChild("ProjectileScript")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}
BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Shape = Enum.PartType.Block
BaseProjectile.Material = Enum.Material.Neon
BaseProjectile.Size = Vector3.new(0.375, 0.375, 1.5)
BaseProjectile.BrickColor = BrickColor.new("Pastel Blue")
BaseProjectile.Reflectance = 0
BaseProjectile.Transparency = 0.1
Create("PointLight"){
	Name = "Light",
	Brightness = 5,
	Color = BaseProjectile.BrickColor.Color,
	Range = 3.5,
	Shadows = false,
	Enabled = true,
	Parent = BaseProjectile,
}
ProjectileSparksCopy = ProjectileSparks:Clone()
ProjectileSparksCopy.Enabled = true
ProjectileSparksCopy.Color = ColorSequence.new(BaseProjectile.BrickColor.Color, BaseProjectile.BrickColor.Color)
ProjectileSparksCopy.Parent = BaseProjectile

Sounds = {
	PewPew = Handle:WaitForChild("PewPew"),
	Hit = Handle:WaitForChild("Hit"),
}

ReloadTime = 0.2

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})

ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

ToolEquipped = false

Tool.Enabled = true

function Fire(Direction)
	
	local SpawnOffset = (Handle.CFrame * CFrame.new(0, 0.25, 0))
	local SpawnPos = (SpawnOffset.p + (Direction * 4))
	
	local Gravity = 196.20
	local Force = 150
	
	local Mass = (BaseProjectile:GetMass() * Gravity)

	local Projectile = BaseProjectile:Clone()
	Projectile.CFrame = CFrame.new(SpawnPos, (CFrame.new(SpawnPos) + Direction * 2).p)
	Projectile.Velocity = (Direction * Force)
	local HitSound = Sounds.Hit:Clone()
	HitSound.Parent = Projectile
	
	local Velocity = (Direction * Force)
	
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Projectile,
	}
	
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = 10},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile,
		}
	end
	
	local ProjectileScriptClone = ProjectileScript:Clone()
	ProjectileScriptClone.Disabled = false
	ProjectileScriptClone.Parent = Projectile
	
	Debris:AddItem(Projectile, 5)
	Projectile.Velocity = Velocity
	Projectile.Parent = game:GetService("Workspace")

	Sounds.PewPew:Play()

end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local TargetPos = MouseData.Position
	local Direction = (TargetPos - Handle.Position).unit
	Tool.Enabled = false
	Fire(Direction)
	wait(ReloadTime)
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
	for i, v in pairs(Sounds) do
		v:Stop()
	end
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
