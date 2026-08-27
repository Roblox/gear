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

ProjectileScript = script:WaitForChild("ProjectileScript")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Shatter = Handle:WaitForChild("Shatter"),
	Whack = Handle:WaitForChild("Whack"),
	Hit = Handle:WaitForChild("Hit"),
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

Ladder = BasePart:Clone()
Ladder.Name = "Ladder"
Ladder.Size = Vector3.new(2, 1.5, 2)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "412771127"),
	TextureId = (BaseUrl .. "412770970"),
	Scale = Vector3.new(1.125, 1.125, 1.125),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Ladder,
}


Umbrella = BasePart:Clone()
Umbrella.Name = "Umbrella"
Umbrella.Size = Vector3.new(1, 1, 3)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "412771199"),
	TextureId = (BaseUrl .. "412771071"),
	Scale = Vector3.new(1.125, 1.125, 1.125),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Umbrella,
}

Mirror = BasePart:Clone()
Mirror.Name = "Mirror"
Mirror.Size = Vector3.new(0.25, 1.65, 2.5)
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "412771155"),
	TextureId = (BaseUrl .. "412771026"),
	Scale = Vector3.new(5, 5, 5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Mirror,
}

UnluckyChance = {Rate = 30, Max = 100}
Gravity = 196.20

ReloadTime = 4

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

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	
	Sounds.Fire.Pitch = (math.random(700, 850) * 0.001)
	Sounds.Fire:Play()
	
	local Projectiles = {Ladder, Umbrella, Mirror}
	
	local ProjectileSelected = Projectiles[math.random(1, #Projectiles)]
	local Projectile = ProjectileSelected:Clone()
	local HitSound
	local UnluckyType = 0
	if ProjectileSelected == Umbrella then
		--UnluckyType = 1
		Projectile.CFrame = (CFrame.new(Projectile.Position) * CFrame.Angles((math.pi / 2), math.rad(math.random(-30, 30)), math.rad(math.random(-360, 360))))
		local Weight = (Projectile:GetMass() * Gravity)
		local BodyGyro = Create("BodyGyro"){
			Name = "BodyGyro",
			D = 500,
			P = 3000,
			maxTorque = Vector3.new(math.huge, math.huge, 0),
			cframe = Projectile.CFrame,
			Parent = Projectile,
		}
		local BodyAngularVelocity = Create("BodyAngularVelocity"){
			Name = "BodyAngularVelocity",
			P = 1250,
			maxTorque = Vector3.new(0, 0, Weight),
			angularvelocity = Vector3.new(0, 0, 1),
			Parent = Projectile,
		}
		local BodyVelocity = Create("BodyVelocity"){
			Name = "BodyVelocity",
			P = 1250,
			maxForce = Vector3.new(0, Weight, 0),
			velocity = Vector3.new(0, -8, 0),
			Parent = Projectile,
		}
		HitSound = Sounds.Hit:Clone()
		HitSound.Pitch = (math.random(2000, 2000) * 0.001)
	else
		if ProjectileSelected == Ladder then
			--UnluckyType = 2
			HitSound = Sounds.Whack:Clone()
			HitSound.Pitch = (math.random(500, 800) * 0.001)
		elseif ProjectileSelected == Mirror then
			--UnluckyType = 3
			HitSound = Sounds.Shatter:Clone()
			HitSound.Pitch = (math.random(900, 1250) * 0.001)
		end
		Projectile.CFrame = (Projectile.CFrame * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360))))
	end
	local MaxTypes = 2
	if (Create("Humanoid"){WalkSpeed = -1}).WalkSpeed < 0 then --Nasty hack to enable reversed WalkSpeed when 0 clamp mistake is fixed.
		MaxTypes = 3
	end
	UnluckyType = math.random(1, MaxTypes)
	if HitSound then
		HitSound.Name = "HitSound"
		HitSound.Parent = Projectile
	end
	
	pcall(function()
		local SpawnPos = (Handle.CFrame * CFrame.new(0, 1, -((Handle.Size.Z / 2) + 0.5)))
		Projectile.CFrame = (SpawnPos * CFrame.Angles(Projectile.CFrame:toEulerAnglesXYZ()))
		SpawnPos = SpawnPos.p
		local TargetPos = MouseData.Position
		
		local Direction = (TargetPos - SpawnPos)
		--Direction = (Direction - Direction.Unit * 5)
		
		local DeltaXZSquared = ((Direction.X ^ 2) + (Direction.Z ^ 2))
		local DeltaXZ = math.sqrt(DeltaXZSquared)
		local DeltaY = Direction.Y
		local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
		local Numerator = (-0.5 * Gravity * DeltaXZSquared)
		local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
		if Denominator == 0 then
			return
		end
		local MaxSpeed = 120
		local MissileSpeed = math.sqrt(Numerator / Denominator)
		if MissileSpeed > MaxSpeed or tostring(MissileSpeed) == tostring(0 / 0) or tostring(MissileSpeed) == tostring(math.huge) then
			MissileSpeed = MaxSpeed
		end
		
		local VectorXZ = (MissileSpeed * math.cos(Alpha))
		local VectorY = (MissileSpeed * math.sin(Alpha))
		local VectorX = (VectorXZ * Direction.X / DeltaXZ)
		local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
		
		Projectile.CanCollide = true
		Projectile.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
		
		local Unlucky = math.random(1, UnluckyChance.Max)
		
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "PushForce", Class = "NumberValue", Value = 20},
			{Name = "Damage", Class = "NumberValue", Value = 0},
			{Name = "Unlucky", Class = "IntValue", Value = ((Unlucky <= UnluckyChance.Rate and UnluckyType) or 0)},
		}
		
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = Projectile,
			}
		end
		
		local ProjectileScriptCopy = ProjectileScript:Clone()
		ProjectileScriptCopy.Disabled = false
		ProjectileScriptCopy.Parent = Projectile
		
		Debris:AddItem(Projectile, 15)
		Projectile.Parent = game:GetService("Workspace")
	end)
	wait(ReloadTime)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)