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

Functions = require(script:WaitForChild("Functions"))

Sounds = {
	ShutDown = Handle:WaitForChild("ShutDown"),
	PoweringUp = Handle:WaitForChild("PoweringUp"),
	Deflect = Handle:WaitForChild("Deflect"),
	Pulse = Handle:WaitForChild("Pulse"),
}

Duration = 5
ReloadTime = 3

ToolEquipped = false

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

SpherePart = BasePart:Clone()
SpherePart.Name = "ProtectionSphere"
SpherePart.Transparency = 0.55
SpherePart.Shape = Enum.PartType.Ball
SpherePart.Size = Vector3.new(2.375, 4.25, 4.25)
SpherePart.CanCollide = false
SpherePart.Anchored = true
SphereMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "427837152"),
	TextureId = (BaseUrl .. "90782359"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 0.375),
	Offset = Vector3.new(0, 0, 0),
	Parent = SpherePart,
}

MaxSphereScale = Vector3.new(5, 5, 5)

Handle.Transparency = 0
Tool.Enabled = true

function CreateReflector(OrientationCFrame)
	local Sphere = SpherePart:Clone()
	Sphere.Transparency = 0.75
	Sphere.Size = Vector3.new(3, 3, 3)
	Sphere.CFrame = OrientationCFrame
	local SphereMesh = Sphere:FindFirstChild("Mesh")
	SphereMesh.Scale = Vector3.new(0.2, 0.2, 0.2)
	Debris:AddItem(Sphere, 3)
	Sphere.Parent = game:GetService("Workspace")
	Spawn(function()
		for i = 1, 3, 0.5 do
			if SphereMesh then
				SphereMesh.Scale = Vector3.new((0.2 * i), (0.2 * i), (0.2 * i)) 
			end
			wait(0.05)
		end
		local MaxScale = SphereMesh.Scale
		for j = 1, 0, -0.1 do
			if SphereMesh then
				SphereMesh.Scale = (MaxScale * j)
				wait(0.05)
			end
		end
	end)
end

function HandleDeflect(Sphere, Part)
	if not Part or not Part.Parent or Part.Anchored or Part.Parent ~= game:GetService("Workspace") or Part.Velocity.Magnitude < 5 or Functions.CalculateRecursiveMass(Part) > 125 then
		return
	end
	if math.acos((Part.CFrame.p - Sphere.CFrame.p).Unit:Dot(Part.Velocity.Unit)) < (math.pi / 2) or (Part.CFrame.p - Sphere.CFrame.p).Magnitude <= 4 then
		return
	end
	local ConnectedParts = Functions.GetAllConnectedParts(Part)
	for i, v in pairs(ConnectedParts) do
		if v and v.Parent then
			local character, humanoid = Functions.FindCharacterAncestor(v)
			if character and character == CurrentCharacter then
				return
			end
		end
	end
	local PartPos = Part.CFrame
	if Part and Part.Parent then
		Part.Anchored = true
		Part.CanCollide = false
		Part.Transparency = 1
		Part:ClearAllChildren()
		Part.Name = "Effect"
		Part:Destroy()
	end
	CreateReflector(CFrame.new(PartPos.p, PartPos.p + ((Sphere.Position - Vector3.new(0, (Sphere.Size.Y / 3), 0)) - PartPos.p).Unit) * CFrame.Angles(0, (math.pi / 2), 0))
	Sounds.Deflect:Play()
	wait(1)
	if not Part or not Part.Parent then
		return
	end
end

function AddFeatures(Sphere, Range)
	local Rate = (1 / 60)
	while Sphere and Sphere.Parent do
		Spawn(function()
			local IgnoreObjects = {CurrentCharacter, Sphere}
			local NegativePartRadius = Vector3.new((Range.X / 2), (Range.Y / 2), (Range.Z / 2))
			local PositivePartRadius = Vector3.new((Range.X / 2), (Range.Y / 2), (Range.Z / 2))
			local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Sphere.Position - NegativePartRadius, Sphere.Position + PositivePartRadius), IgnoreObjects, 100)
			for i, v in pairs(Parts) do
				if v and v.Parent then
					HandleDeflect(Sphere, v)
				end
			end
		end)
		wait(Rate)
	end
end

function TweenScale(SphereMesh, StartSize, EndSize, TweenDuration, Steps)
	local StepSize = (TweenDuration / Steps)
	for i = 0, Steps do
		local Ratio = (i / Steps)
		SphereMesh.Scale = ((1 - Ratio) * StartSize + (EndSize * Ratio))
		wait(StepSize)
	end
	SphereMesh.Scale = EndSize
end

function TweenCFrame(Sphere, StartCFrame, EndCFrame, TweenDuration, Steps)
	local StepSize = (TweenDuration / Steps)
	for i = 0, Steps do
		local Ratio = (i / Steps)
		Sphere.CFrame = (CFrame.new((1 - Ratio) * StartCFrame.p + (EndCFrame.p * Ratio)) * CFrame.Angles(Sphere.CFrame:toEulerAnglesXYZ()))
		wait(StepSize)
	end
	Sphere.CFrame = EndCFrame
end

function Activated()
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	CurrentCharacter = Character
	CurrentTorso = Torso
	
	local Sphere = SpherePart:Clone()
	local SphereMesh = Sphere:FindFirstChild("Mesh")
	Debris:AddItem(Sphere, Duration)
	Sphere.Parent = game:GetService("Workspace")
	local TorsoCFrame = (CFrame.new(CurrentTorso.Position) * CFrame.Angles(0, 0, -(math.pi / 2)))
	Sphere.CFrame = TorsoCFrame
	Spawn(function()
		TweenScale(SphereMesh, Vector3.new(0.1, 0.1, 0.1), MaxSphereScale, 0.5, 10)
	end)
	Spawn(function()
		TweenCFrame(Sphere, TorsoCFrame, (TorsoCFrame + Vector3.new(0, 2.75, 0)), 0.5, 10)
	end)
	Sounds.PoweringUp:Play()
	Spawn(function()
		AddFeatures(Sphere, (Sphere.Size * MaxSphereScale.X))
	end)
	wait((Duration - 1.5))
	Sounds.ShutDown:Play()
	wait(1.5)
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player.Parent and Humanoid.Parent and Humanoid.Health > 0 and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
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