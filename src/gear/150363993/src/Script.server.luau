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

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseSun = BasePart:Clone()
BaseSun.Name = "Effect"
BaseSun.Size = Vector3.new(0.2, 0.2, 0.2)
BaseSun.CanCollide = false
BaseSun.Locked = true
BaseSun.TopSurface = Enum.SurfaceType.Smooth
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "150062886"),
	TextureId = (BaseUrl .. "150062934"),
	Scale = Vector3.new(3.5, 3.5, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseSun,
}

BaseFlowers = BasePart:Clone()
BaseFlowers.Name = "Effect"
BaseFlowers.Size = Vector3.new(0.2, 0.2, 0.2)
BaseFlowers.CanCollide = false
BaseFlowers.Locked = true
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "150062910"),
	TextureId = (BaseUrl .. "150062934"),
	Scale = Vector3.new(1.5, 1.5, 1.5),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseFlowers,
}

Gravity = 196.20

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function Activated()
	if (Sun and Sun.Parent) or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Handle.Transparency = 1
	Sun = BaseSun:Clone()
	local Mass = (Sun:GetMass() * Gravity ^ 2)
	local BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		Parent = Sun,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(Mass, Mass, Mass),
		Parent = Sun,
	}
	Sun.CFrame = Handle.CFrame
	Sun.Parent = Tool
	local FlowerTick = 0
	Spawn(function()
		while Sun and Sun.Parent and CheckIfAlive() and ToolEquipped do
			local Now = tick()
			BodyPosition.position = (Head.CFrame * CFrame.new(((Head.Size.X / 2) - 3), ((Head.Size.Y / 2) + 10), ((Head.Size.Z / 2) + 5))).p
			BodyGyro.cframe = CFrame.new(Sun.Position, (Head.Position + Vector3.new(1.5, 7.5, 0)))
			if (Now - FlowerTick) >= 0.5 and (Torso.Velocity * Vector3.new(1, 0, 1)).Magnitude > 5 then
				FlowerTick = Now
				local RayHit, RayPos, RayNormal = CastRay((Torso.CFrame - Torso.CFrame.lookVector * Torso.Size.Z).p, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character}, false)
				if RayHit then
					local Flowers = BaseFlowers:Clone()
					local PX, PY, PZ, RXX, RXY, RXZ, RYX, RYY, RYZ, RZX, RZY, RZZ = Torso.CFrame:components()
					local FlowerCFrame = CFrame.new(RayPos.X, (RayPos.Y + ((Flowers.Size.Y / 2) - Flowers.Size.Y)), RayPos.Z, RXX, RXY, RXZ, RYX, RYY, RYZ, RZX, RZY, RZZ)
					Flowers.CFrame = FlowerCFrame
					local PartCFrame = CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
					PartCFrame = (PartCFrame * CFrame.new(0, -(Flowers.Size.Y / 1.5), 0))
					PartCFrame = CFrame.new(PartCFrame.p.X, PartCFrame.p.Y, PartCFrame.p.Z, RXX, RXY, RXZ, RYX, RYY, RYZ, RZX, RZY, RZZ)
					local Weld = Create("Motor6D"){
						Part0 = Flowers,
						Part1 = RayHit,
						C0 = PartCFrame:inverse(),
						C1 = RayHit.CFrame:inverse(),
						Parent = Flowers,
					}
					Spawn(function()
						local Rate = 0.05
						for i = Rate, (1.9 / 2), Rate do
							Weld.C0 = (Weld.C0 - Vector3.new(0, Rate, 0))
							wait(0.01)
						end
					end)
					Debris:AddItem(Flowers, 20)
					Flowers.Parent = game:GetService("Workspace")
				end
			end
			wait()
		end
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Handle.Transparency = 0
end

function Unequipped()
	Handle.Transparency = 0
	if Sun and Sun.Parent then
		Sun:Destroy()
	end
	ToolEquipped = false
end

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)