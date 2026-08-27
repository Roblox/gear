--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


Animation = script:WaitForChild("Animation")

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

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CreateBackpack(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("BasePart") or v:IsA("Model")) and v ~= Handle then
			v:Destroy()
		end
	end
	if ReduceDamage then
		ReduceDamage:disconnect()
	end
	Handle.Transparency = ((MakeNew and 1) or 0)
	if not MakeNew or not CheckIfAlive() then
		return
	end
	IgnoreHealthChange = false
	local CurrentHealth = Humanoid.Health
	ReduceDamage = Humanoid.Changed:connect(function(Property)
		local NewHealth = Humanoid.Health
		if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
			if NewHealth < CurrentHealth then
				local DamageDealt = (CurrentHealth - NewHealth)
				IgnoreHealthChange = true
				Humanoid.Health = (Humanoid.Health + (DamageDealt * 0.6))
				IgnoreHealthChange = false
			end
		end
		CurrentHealth = NewHealth
	end)
	local TurtleBackpack = Create("Model"){
		Name = "TurtleBackpack",
	}
	local Shell = BasePart:Clone()
	Shell.Name = "Shell"
	Shell.Size = Vector3.new(2, 2, 1)
	Shell.CanCollide = false
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "471843937"),
		TextureId = (BaseUrl .. "471844626"),
		VertexColor = Vector3.new(1, 1, 1),
		Scale = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Shell,
	}
	Shell.Parent = TurtleBackpack
	local Fins = {
		{MeshId = 471844190, Name = "BottomLeftFin", C0 = CFrame.new(-0.703393877, -1.42692041, 0.260600388, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1), C1 = CFrame.new(0.349999964, 0.349998474, 0.0500000119, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1)},
		{MeshId = 471843792, Name = "BottomRightFin", C0 = CFrame.new(0.709276319, -1.42692041, 0.260600388, -4.37113883e-008, -1, 0, 1, -4.37113883e-008, 0, 0, 0, 1), C1 = CFrame.new(-0.350000024, 0.349998474, 0.0500000119, -4.37113883e-008, -1, 0, 1, -4.37113883e-008, 0, 0, 0, 1)},
		{MeshId = 471844430, Name = "TopLeftFin", C0 = CFrame.new(-0.832682014, 0.162908971, 0.250124335, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1), C1 = CFrame.new(0.449999928, 0.650001526, 0.25, -4.37113883e-008, 1, 0, -1, -4.37113883e-008, 0, 0, 0, 1)},
		{MeshId = 471844318, Name = "TopRightFin", C0 = CFrame.new(0.733196378, 0.212908924, 0.0482223518, -4.37113883e-008, -1, 0, 1, -4.37113883e-008, 0, 0, 0, 1), C1 = CFrame.new(-0.550000072, 0.700000763, 0.0500000007, -4.37113883e-008, -1, 0, 1, -4.37113883e-008, 0, 0, 0, 1)},
	}
	for i, v in pairs(Fins) do
		local Fin = Shell:Clone()
		Fin.Name = v.Name
		Fin.Size = Vector3.new(0.2, 0.2, 0.2)
		Fin.CanCollide = false
		Fin.Mesh.MeshId = (BaseUrl .. v.MeshId)
		Create("Motor6D"){
			Name = v.Name,
			Part0 = Shell,
			Part1 = Fin,
			C0 = v.C0,
			C1 = v.C1,
			MaxVelocity = 0.01,
			Parent = Shell,
		}
		local AnimationScript = Animation:Clone()
		AnimationScript.Disabled = false
		AnimationScript.Parent = TurtleBackpack
		Fin.Parent = TurtleBackpack
	end
	local ShellWeld = Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = Shell,
		C0 = CFrame.new(0, 0.35, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = Shell,
	}
	TurtleBackpack.Parent = Tool
end

function Activated()
	if not Tool.Enabled then
		return
	end
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
	Spawn(function()
		CreateBackpack(true)
	end)
end

function Unequipped()
	ToolEquipped = false
	Spawn(function()
		CreateBackpack(false)
	end)
end

Delay(0, (function()
	if not ToolEquipped then
		CreateBackpack(false)
	end
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)