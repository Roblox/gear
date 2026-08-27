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

ProjectileScript = script:WaitForChild("ProjectileScript")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Velocity = 110
VelocitySquared = (Velocity ^ 2)
VelocityToFourth = (Velocity ^ 4)

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	Reload = Handle:WaitForChild("Reload"),
	Swoosh = Handle:WaitForChild("Swoosh"),
}

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Size = Vector3.new(0.84, 1.59, 1.2)
BaseProjectile.CanCollide = false
ProjectileMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "128149461"),
	TextureId = (BaseUrl .. "128149527"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile
}

Gravity = 196.20

CoolDown = 4

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

function ComputeLaunchAngle(dx, dy) --http://en.wikipedia.org/wiki/Trajectory_of_a_projectile
	local g = math.abs(Gravity)
	local inRoot = (VelocityToFourth) - (g * ((g*dx*dx) + (2*dy*VelocitySquared)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VelocitySquared) + root) / (g*dx)
	local inATan2 = ((VelocitySquared) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	return math.min(answer1,answer2)
end

function MakeProjectile()
	
	local Projectile = BaseProjectile:Clone()
	
	local Fire = Create("Fire"){
		Name = "Fire",
		Color = Color3.new((236 / 255), (139 / 255), (70 / 255)),
		SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255)),
		Heat = 9,
		Size = 5,
		Enabled = true,
		Parent = Projectile,
	}

	local Spin = Create("BodyAngularVelocity"){
		maxTorque = Vector3.new(999999, 999999, 999999),
		angularvelocity = Vector3.new((math.random() * 30 - 15), (math.random() * 30 - 15), (math.random() * 30 - 15)),
		Parent = Projectile,
	}
	
	local Creator = Create("ObjectValue"){
		Name = "Creator",
		Value = Player,
		Parent = Projectile,
	}
	
	local ProjectileScriptCopy = ProjectileScript:Clone()
	ProjectileScriptCopy.Disabled = false
	ProjectileScriptCopy.Parent = Projectile
	
	return Projectile
	
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Activated()
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition or not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local TargetPosition = MousePosition.Position
	local SpawnPosition = (Handle.Position + (Handle.CFrame.lookVector * (Handle.Size.z / 2)))
	
	local ProjectileClone = MakeProjectile()
	
	ProjectileClone.CFrame = CFrame.new(SpawnPosition, TargetPosition)

	local Direction = (TargetPosition - SpawnPosition).Unit
	local Launch = (SpawnPosition + 3 * Direction)
	local Delta = (TargetPosition - Launch)
	local DY = Delta.Y
	Delta = (Delta * Vector3.new(1, 0, 1))
	local DX = Delta.magnitude
	local UnitDelta = Delta.Unit
	local Theta = ComputeLaunchAngle(DX, DY)
	local XZ = math.cos(Theta)
	local VY = math.sin(Theta)
	local VX = (UnitDelta.X * XZ)
	local VZ = (UnitDelta.Z * XZ)
	
	ProjectileClone.Velocity = (Vector3.new(VX, VY, VZ) * Velocity)
	
	local SwooshSound = Sounds.Swoosh:Clone()
	SwooshSound.Parent = ProjectileClone
	
	Debris:AddItem(ProjectileClone, 10)
	ProjectileClone.Parent = game:GetService("Workspace")
	
	SwooshSound:Play()
	
	Sounds.Reload:Play()
	
	wait(CoolDown)
	
	Sounds.Reload:Stop()
	
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Equip:Play()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
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