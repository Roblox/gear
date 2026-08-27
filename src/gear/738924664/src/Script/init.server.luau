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


BaseUrl = "rbxassetid://"
ProjectileScript = script:WaitForChild("ProjectileScript")

Sounds = {
	Release = Handle:WaitForChild("Release"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

Projectile = BasePart:Clone()
Projectile.Name = "Projectile"
Projectile.Size = Vector3.new(0.375, 2.156, 0.375)
Projectile.CanCollide = false
ProjectileMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "738672221"),
	TextureId = (BaseUrl .. "738673171"),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Scale = Mesh.Scale,
	Parent = Projectile,
}
ProjectileWeld = Create("Weld"){
	Name = "Weld",
	Part0 = nil,
	Part1 = Projectile,
	C0 = CFrame.new(-0.300000012, -1.17355692, -3.8067174, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	C1 = CFrame.new(-0.279118657, -1.47664058, -3.34687614, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Parent = Projectile
}

ProjectileReady = true
ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Tool.Enabled = true

function CreateProjectile()
	if not ToolEquipped or not CheckIfAlive() or not String or not String.Parent then
		return
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "Projectile" then
			v:Destroy()
		end
	end
	if ProjectileCopy and ProjectileCopy.Parent then
		ProjectileCopy:Destroy()
	end
	ProjectileCopy = Projectile:Clone()
	ProjectileWeld = ProjectileCopy.Weld
	ProjectileWeld.Part0 = ProjectileCopy
	ProjectileWeld.Part1 = String
	ProjectileWeld.Parent = ProjectileCopy
	ProjectileCopy.Parent = Tool
end

function ReadySling(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	String = BasePart:Clone()
	String.Name = "String"
	String.CanCollide = false
	StringMesh = Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "738672513"),
		TextureId = (BaseUrl .. "738672705"),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Scale = Mesh.Scale,
		Parent = String,
	}
	Motor = Create("Motor"){
		Name = "Sling",
		Part0 = Handle,
		Part1 = String,
		C0 = CFrame.new(0.0166186374, 0.923503339, 0.12187627, -4.37113883e-008, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-008),
		C1 = CFrame.new(0.0375000015, 0.525000572, -0.375, -4.37113883e-008, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-008),
		CurrentAngle = 0,
		DesiredAngle = 0,
		MaxVelocity = 0.1,
		Parent = String,
	}
	String.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or not ProjectileReady then
		return
	end
	if not String or not String.Parent or not Motor or not Motor.Parent then
		return
	end
	Tool.Enabled = false
	ProjectileReady = false
	Sounds.Release:Play()
	Motor.DesiredAngle = 1
	if ProjectileCopy and ProjectileCopy.Parent then
		Spawn(function()
			local MaxPower = 85
			local CurrentProjectile = ProjectileCopy
			ProjectileCopy = nil
			local SpawnPos = CurrentProjectile.Position
			local TargetPos = MouseData.Position
			
			local Direction = (TargetPos - SpawnPos)
			Direction = (Direction - Direction.unit * 5)
			
			local Gravity = game:GetService("Workspace").Gravity
			
			local DeltaXZSquared = ((Direction.X ^ 2) + (Direction.Z ^ 2))
			local DeltaXZ = math.sqrt(DeltaXZSquared)
			local DeltaY = Direction.Y
			local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
			local Numerator = (-0.5 * Gravity * DeltaXZSquared)
			local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
			if Denominator == 0 then
				return
			end
			local MissileSpeed = math.sqrt(Numerator / Denominator)
			if MissileSpeed > MaxPower or tostring(MissileSpeed) == "-1.#IND" or tostring(MissileSpeed) == "1.#INF" then
				MissileSpeed = MaxPower
			end
			
			local VectorXZ = (MissileSpeed * math.cos(Alpha))
			local VectorY = (MissileSpeed * math.sin(Alpha))
			local VectorX = (VectorXZ * Direction.X / DeltaXZ)
			local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
			
			if ProjectileWeld and ProjectileWeld.Parent then
				ProjectileWeld:Destroy()
			end
			
			CurrentProjectile.CanCollide = true
			CurrentProjectile.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
			
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = 10},
			}
			
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = CurrentProjectile,
				}
			end
			
			local ProjectileScriptCopy = ProjectileScript:Clone()
			ProjectileScriptCopy.Disabled = false
			ProjectileScriptCopy.Parent = CurrentProjectile
			
			Debris:AddItem(CurrentProjectile, 3)
			
			CurrentProjectile.Parent = game:GetService("Workspace")
			
		end)
	end
	Delay(0.75, (function()
		Motor.DesiredAngle = 0
	end))
	wait(1)
	CreateProjectile()
	ProjectileReady = true
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
	Spawn(function()
		ReadySling(true)
		if ProjectileReady then
			CreateProjectile()
		end
	end)
end

function Unequipped()
	Spawn(function()
		ReadySling(true)
	end)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Delay(0, (function()
	if ToolEquipped then
		return
	end
	ReadySling(true)
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)