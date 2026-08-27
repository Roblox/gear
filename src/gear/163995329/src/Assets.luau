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
		Body = 162958671,
		FrontWheel = 162958695,
		BackWheel = 162958639,
	},
	TextureId = 162958751
}

function CreateVehicle()

	local ExhaustSmoke = {}
	local Lights = {}
	local Sparkles = {}

	local Body = BasePart:Clone()
	Body.Name = "Body"
	Body.Size = Vector3.new(1, 5.125, 6)
	local BodyMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.Body,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Body
	}
	
	local BaseWheel = BasePart:Clone()
	BaseWheel.Size = Vector3.new(0.5, 1, 1)
	BaseWheel.CanCollide = false
	local WheelMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = "",
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseWheel,
	}

	local BaseFrontWheel = BaseWheel:Clone()
	BaseFrontWheel.Name = "FrontWheel"
	BaseFrontWheel.Mesh.MeshId = MeshData.Meshes.FrontWheel
	
	local BaseBackWheel = BaseWheel:Clone()
	BaseBackWheel.Name = "BackWheel"
	BaseBackWheel.Mesh.MeshId = MeshData.Meshes.BackWheel

	local BaseSmokePart = BasePart:Clone()
	BaseSmokePart.Name = "SmokePart"
	BaseSmokePart.Transparency = 1
	BaseSmokePart.Size = Vector3.new(0.52, 0.52, 1.25)
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
	local Light = Create("PointLight"){
		Name = "Light",
		Brightness = 50,
		Color = Color3.new((255 / 255), (252 / 255), (153 / 255)),
		Range = 10,
		Shadows = false,
		Enabled = false,
		Parent = BaseLightPart,
	}
	for i = 1, 5 do
		local BaseSparkles = Create("Sparkles"){
			SparkleColor = Color3.new((0 / 255), (255 / 255), (0 / 255)),
			Enabled = false,
			Parent = BaseLightPart,
		}
	end
		
	local FrontWheel = BaseFrontWheel:Clone()
	FrontWheel.Parent = Body
	
	local FrontMotor = Create("Motor6D"){
		Name = "FrontMotor",
		Part0 = Body,
		Part1 = FrontWheel,
		C0 = CFrame.new(0, -2.05, -1.775) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, -(math.pi / 2), 0),
		Parent = Body
	}
	
	local BackWheel = BaseBackWheel:Clone()
	BackWheel.Parent = Body
	
	local BackMotor = Create("Motor6D"){
		Name = "BackMotor",
		Part0 = Body,
		Part1 = BackWheel,
		C0 = CFrame.new(0, -2.05, 2.7) * CFrame.Angles(0, (math.pi / 2), 0),
		C1 = CFrame.new() * CFrame.Angles(0, -(math.pi / 2), 0),
		Parent = Body
	}
	
	local ExhaustPipe = BaseSmokePart:Clone()
	ExhaustPipe.Name = "LeftExhaustPipe"
	ExhaustPipe.Parent = Body
	table.insert(ExhaustSmoke, ExhaustPipe.ExhaustSmoke)
	
	local SmokeWeld = Create("Weld"){
		C0 = CFrame.new(0, 1.375, -2.375) * CFrame.Angles(0, 0, 0),
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