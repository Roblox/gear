--Made by Luckymaxer

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


BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true
}

MeshData = {
	Meshes = {
		Body = 1920157930,
		Wheel = 1920159024,
	},
	TextureId = 1920157072,
}

function CreateVehicle()

	local ExhaustSmoke = {}
	local Lights = {}
	local Sparkles = {}
	
	local Body = BasePart:Clone()
	Body.Name = "Body"
	Body.Size = Vector3.new(6.25, 3.5, 12)
	local BodyMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.Body,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(2, 2, 2),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Body
	}
	
	local BaseWheel = BasePart:Clone()
	BaseWheel.Size = Vector3.new(0.5, 1, 1)
	BaseWheel.CanCollide = false
	local WheelMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.Wheel,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(2, 2, 2),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseWheel,
	}

	local BaseFrontWheel = BaseWheel:Clone()
	BaseFrontWheel.Name = "FrontWheel"
	
	local BaseBackWheel = BaseWheel:Clone()
	BaseBackWheel.Name = "BackWheel"

	local BaseSmokePart = BasePart:Clone()
	BaseSmokePart.Name = "SmokePart"
	BaseSmokePart.Transparency = 1
	BaseSmokePart.CanCollide = false
	local BaseExhaustSmoke = Create("Smoke"){
		Name = "ExhaustSmoke",
		Size = 0.1,
		RiseVelocity = 0.01,
		Color = Color3.new((127 / 255), (127 / 255), (127 / 255)),
		Enabled = true,
		Parent = BaseSmokePart,
	}

	local BaseLightPart = BasePart:Clone()
	BaseLightPart.Name = "LightPart"
	BaseLightPart.Transparency = 1
	BaseLightPart.CanCollide = false
	local Light = Create("SpotLight"){
		Name = "Light",
		Brightness = 5,
		Angle = 45,
		Color = Color3.new(255 / 255, 252 / 255, 153 / 255),
		Range = 30,
		Shadows = false,
		Enabled = false,
		Parent = BaseLightPart,
	}
			
	local FrontLeftWheel = BaseFrontWheel:Clone()
	FrontLeftWheel.Name = "FrontLeftWheel"
	FrontLeftWheel.Parent = Body
	
	local FrontLeftMotor = Create("Motor6D"){
		Name = "FrontLeftMotor",
		Part0 = Body,
		Part1 = FrontLeftWheel,
		C0 = CFrame.new(-2.375, -0.85, -3.9) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, (math.pi / 2), 0),
		Parent = Body
	}
	
	local FrontRightWheel = BaseFrontWheel:Clone()
	FrontRightWheel.Name = "FrontRightWheel"
	FrontRightWheel.Parent = Body
	
	local FrontRightMotor = Create("Motor6D"){
		Name = "FrontRightMotor",
		Part0 = Body,
		Part1 = FrontRightWheel,
		C0 = CFrame.new(2.375, -0.85, -3.9) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, -(math.pi / 2), 0),
		Parent = Body
	}
	
	local BackLeftWheel = BaseBackWheel:Clone()
	BackLeftWheel.Name = "BackLeftWheel"
	BackLeftWheel.Parent = Body
	
	local BackLeftMotor = Create("Motor6D"){
		Name = "BackLeftMotor",
		Part0 = Body,
		Part1 = BackLeftWheel,
		C0 = CFrame.new(-2.125, -0.85, 3.65) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, (math.pi / 2), 0),
		Parent = Body
	}
	
	local BackRightWheel = BackLeftWheel:Clone()
	BackRightWheel.Name = "BackRightWheel"
	BackRightWheel.Parent = Body
	
	local BackRightMotor = Create("Motor6D"){
		Name = "BackRightMotor",
		Part0 = Body,
		Part1 = BackRightWheel,
		C0 = CFrame.new(2.125, -0.85, 3.65) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, -(math.pi / 2), 0),
		Parent = Body
	}
	
	local HeadLight = BaseLightPart:Clone()
	HeadLight.Parent = Body
	table.insert(Lights, HeadLight.Light)
	for i, v in pairs(HeadLight:GetChildren()) do
		if v:IsA("Sparkles") then
			table.insert(Sparkles, v)
		end
	end
	
	local LightWeld = Create("Weld"){
		Part0 = Body,
		Part1 = HeadLight,
		C0 = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0),
		Parent = HeadLight
	}
	
	local ExhaustPipe = BaseSmokePart:Clone()
	ExhaustPipe.Name = "ExhaustPipe"
	ExhaustPipe.Parent = Body
	table.insert(ExhaustSmoke, ExhaustPipe.ExhaustSmoke)
	
	local SmokeWeld = Create("Weld"){
		C0 = CFrame.new(0, 0, -8.25) * CFrame.Angles(0, 0, 0),
		Part0 = ExhaustPipe,
		Part1 = Body,
		Parent = ExhaustPipe
	}

	local Tables = {
		ExhaustSmoke = ExhaustSmoke,
		Lights = Lights,
		Sparkles = Sparkles
	}
	
	return {
		Vehicle = Body,
		Tables = Tables
	}
	
end

for i, v in pairs(MeshData) do
	if type(v) == "table" then
		for ii, vv in pairs(v) do
			if type(vv) == "string" or type(vv) == "number" then
				MeshData[i][ii] = (BaseUrl .. tostring(vv))
			end
		end
	elseif type(v) == "string" or type(v) == "number" then
		MeshData[i] = (BaseUrl .. tostring(v))
	end
end

return {
	BaseUrl = BaseUrl,
	MeshData = MeshData,
	CreateVehicle = CreateVehicle
}