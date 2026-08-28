BaseUrl = "rbxassetid://"

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


--[[
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
]]

BaseVehicle = script.AquaRoped:Clone()
BaseVehicle.Transparency = 0
script.AquaRoped:Destroy()

--[[
MeshData = {
	Meshes = {
		Body = 915243377,
		HandleBars = 218513951,
		HoverPiece1 = 218514065,
		HoverPiece2 = 218514114,
		HoverPiece3 = 218514147,
		SmallHoverPiece1 = 218514214,
		SmallHoverPiece2 = 218514260,
	},
	TextureId = 915243557
}
]]

function CreateVehicle()

	local ExhaustSmoke = {}
	local Lights = {}
	local Sparkles = {}
	local HoverParts = {}
	
	local Body = BaseVehicle:Clone()
	--[[
	local Body = BasePart:Clone()
	Body.Name = "Body"
	Body.Size = Vector3.new(1.75, 1.35, 4.25)
	local BodyMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.Body,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Body
	}
	
	local BaseHoverPiece1 = BasePart:Clone()
	BaseHoverPiece1.Name = "HoverPiece1"
	BaseHoverPiece1.CanCollide = false
	local BottomHoverPiece1BarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.HoverPiece1,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseHoverPiece1,
	}
	
	local BaseHoverPiece2 = BasePart:Clone()
	BaseHoverPiece2.Name = "HoverPiece2"
	BaseHoverPiece2.CanCollide = false
	local BottomHoverPiece2BarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.HoverPiece2,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseHoverPiece2,
	}
	
	local BaseHoverPiece3 = BasePart:Clone()
	BaseHoverPiece3.Name = "HoverPiece3"
	BaseHoverPiece3.CanCollide = false
	local BottomHoverPiece3BarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.HoverPiece3,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseHoverPiece3,
	}
	
	local BaseSmallHoverPiece1 = BasePart:Clone()
	BaseSmallHoverPiece1.Name = "SmallHoverPiece2"
	BaseSmallHoverPiece1.CanCollide = false
	local BottomHoverPiece3BarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.SmallHoverPiece1,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseSmallHoverPiece1,
	}
	
	local BaseSmallHoverPiece2 = BasePart:Clone()
	BaseSmallHoverPiece2.Name = "SmallHoverPiece1"
	BaseSmallHoverPiece2.CanCollide = false
	local BottomHoverPiece3BarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.SmallHoverPiece2,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseSmallHoverPiece2,
	}

	local BaseLightPart = BasePart:Clone()
	BaseLightPart.Name = "LightPart"
	BaseLightPart.Transparency = 1
	local Light = Create("PointLight"){
		Name = "Light",
		Brightness = 50,
		Color = Color3.new((0 / 255), (252 / 255), (255 / 255)),
		Range = 7,
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
		C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
		Parent = HeadLight
	}

	local HandleBars = BasePart:Clone()
	HandleBars.Name = "HandleBars"
	HandleBars.Size = Vector3.new(3, 0.75, 0.25)
	HandleBars.CanCollide = false
	local HandleBarsMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.HandleBars,
		TextureId = MeshData.TextureId,
		Scale = Vector3.new(4, 4, 4),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = HandleBars,
	}
	local HandleBarsWeld = Create("Weld"){
		Part0 = Body,
		Part1 = HandleBars,
		C0 = CFrame.new(0, 3.45, -1.55) * CFrame.Angles(0, 0, 0),
		Parent = HandleBars
	}
	HandleBars.Parent = Body
	
	local BottomHoverPiece1 = BaseHoverPiece1:Clone()
	BottomHoverPiece1.Name = "BottomHoverPiece3"
	local BottomHoverPiece1Weld = Create("Weld"){
		Part0 = Body,
		Part1 = BottomHoverPiece1,
		C0 = CFrame.new(0, 0.545, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = BottomHoverPiece1
	}
	BottomHoverPiece1.Parent = Body
	table.insert(HoverParts, BottomHoverPiece1)
	
	local BottomHoverPiece2 = BaseHoverPiece2:Clone()
	BottomHoverPiece2.Name = "BottomHoverPiece2"
	local BottomHoverPiece2Weld = Create("Weld"){
		Part0 = Body,
		Part1 = BottomHoverPiece2,
		C0 = CFrame.new(0, 0.288, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = BottomHoverPiece2
	}
	BottomHoverPiece2.Parent = Body
	table.insert(HoverParts, BottomHoverPiece2)

	local BottomHoverPiece3 = BaseHoverPiece3:Clone()
	BottomHoverPiece3.Name = "BottomHoverPiece1"
	local BottomHoverPiece3Weld = Create("Weld"){
		Part0 = Body,
		Part1 = BottomHoverPiece3,
		C0 = CFrame.new(0, 0.0775, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = BottomHoverPiece3
	}
	BottomHoverPiece3.Parent = Body
	table.insert(HoverParts, BottomHoverPiece3)
	
	local TopHoverPiece3 = BaseHoverPiece3:Clone()
	TopHoverPiece3.Name = "TopHoverPiece1"
	local TopHoverPiece3Weld = Create("Weld"){
		Part0 = Body,
		Part1 = TopHoverPiece3,
		C0 = CFrame.new(0, 2.945, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = TopHoverPiece3
	}
	TopHoverPiece3.Parent = Body
	table.insert(HoverParts, TopHoverPiece3)
	
	local TopHoverPiece2 = BaseHoverPiece2:Clone()
	TopHoverPiece2.Name = "TopHoverPiece2"
	local TopHoverPiece2Weld = Create("Weld"){
		Part0 = Body,
		Part1 = TopHoverPiece2,
		C0 = CFrame.new(0, 2.7225, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = TopHoverPiece2
	}
	TopHoverPiece2.Parent = Body
	table.insert(HoverParts, TopHoverPiece2)

	local TopHoverPiece1 = BaseHoverPiece1:Clone()
	TopHoverPiece1.Name = "TopHoverPiece3"
	local TopHoverPiece1Weld = Create("Weld"){
		Part0 = Body,
		Part1 = TopHoverPiece1,
		C0 = CFrame.new(0, 2.49, -1.565) * CFrame.Angles(0, 0, 0),
		Parent = TopHoverPiece1
	}
	TopHoverPiece1.Parent = Body
	table.insert(HoverParts, TopHoverPiece1)
	
	local BackLeftHoverPiece = BaseSmallHoverPiece2:Clone()
	local BackLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = BackLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.275, 1.3325) * CFrame.Angles(0, 0, 0),
		Parent = BackLeftHoverPiece
	}
	BackLeftHoverPiece.Parent = Body
	table.insert(HoverParts, BackLeftHoverPiece)
	local SmallBackLeftHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallBackLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallBackLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.425, 1.3325) * CFrame.Angles(0, 0, 0),
		Parent = SmallBackLeftHoverPiece
	}
	SmallBackLeftHoverPiece.Parent = Body
	table.insert(HoverParts, SmallBackLeftHoverPiece)
	
	local MiddleBackLeftHoverPiece = BaseSmallHoverPiece2:Clone()
	local MiddleBackLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = MiddleBackLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.275, 0.435) * CFrame.Angles(0, 0, 0),
		Parent = MiddleBackLeftHoverPiece
	}
	MiddleBackLeftHoverPiece.Parent = Body
	table.insert(HoverParts, MiddleBackLeftHoverPiece)
	local SmallMiddleBackLeftHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallMiddleBackLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallMiddleBackLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.425, 0.435) * CFrame.Angles(0, 0, 0),
		Parent = SmallMiddleBackLeftHoverPiece
	}
	SmallMiddleBackLeftHoverPiece.Parent = Body
	table.insert(HoverParts, SmallMiddleBackLeftHoverPiece)
	
	local MiddleFrontLeftHoverPiece = BaseSmallHoverPiece2:Clone()
	local MiddleFrontLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = MiddleFrontLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.275, -0.635) * CFrame.Angles(0, 0, 0),
		Parent = MiddleFrontLeftHoverPiece
	}
	MiddleFrontLeftHoverPiece.Parent = Body
	table.insert(HoverParts, MiddleFrontLeftHoverPiece)
	local SmallMiddleFrontLeftHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallMiddleFrontLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallMiddleFrontLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.425, -0.635) * CFrame.Angles(0, 0, 0),
		Parent = SmallMiddleFrontLeftHoverPiece
	}
	SmallMiddleFrontLeftHoverPiece.Parent = Body
	table.insert(HoverParts, SmallMiddleFrontLeftHoverPiece)
	
	local FrontLeftHoverPiece = BaseSmallHoverPiece2:Clone()
	local FrontLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = FrontLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.275, -1.5625) * CFrame.Angles(0, 0, 0),
		Parent = FrontLeftHoverPiece
	}
	FrontLeftHoverPiece.Parent = Body
	table.insert(HoverParts, FrontLeftHoverPiece)
	local SmallFrontLeftHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallFrontLeftHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallFrontLeftHoverPiece,
		C0 = CFrame.new(-0.28, -0.425, -1.5625) * CFrame.Angles(0, 0, 0),
		Parent = SmallFrontLeftHoverPiece
	}
	SmallFrontLeftHoverPiece.Parent = Body
	table.insert(HoverParts, SmallFrontLeftHoverPiece)
	
	local BackRightHoverPiece = BaseSmallHoverPiece2:Clone()
	local BackRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = BackRightHoverPiece,
		C0 = CFrame.new(0.28, -0.275, 1.3325) * CFrame.Angles(0, 0, 0),
		Parent = BackRightHoverPiece
	}
	BackRightHoverPiece.Parent = Body
	table.insert(HoverParts, BackRightHoverPiece)
	local SmallBackRightHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallBackRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallBackRightHoverPiece,
		C0 = CFrame.new(0.28, -0.425, 1.3325) * CFrame.Angles(0, 0, 0),
		Parent = SmallBackRightHoverPiece
	}
	SmallBackRightHoverPiece.Parent = Body
	table.insert(HoverParts, SmallBackRightHoverPiece)
	
	local MiddleBackRightHoverPiece = BaseSmallHoverPiece2:Clone()
	local MiddleBackRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = MiddleBackRightHoverPiece,
		C0 = CFrame.new(0.28, -0.275, 0.435) * CFrame.Angles(0, 0, 0),
		Parent = MiddleBackRightHoverPiece
	}
	MiddleBackRightHoverPiece.Parent = Body
	table.insert(HoverParts, MiddleBackRightHoverPiece)
	local SmallMiddleBackRightHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallMiddleBackRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallMiddleBackRightHoverPiece,
		C0 = CFrame.new(0.28, -0.425, 0.435) * CFrame.Angles(0, 0, 0),
		Parent = SmallMiddleBackRightHoverPiece
	}
	SmallMiddleBackRightHoverPiece.Parent = Body
	table.insert(HoverParts, SmallMiddleBackRightHoverPiece)
	
	local MiddleFrontRightHoverPiece = BaseSmallHoverPiece2:Clone()
	local MiddleFrontRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = MiddleFrontRightHoverPiece,
		C0 = CFrame.new(0.28, -0.275, -0.635) * CFrame.Angles(0, 0, 0),
		Parent = MiddleFrontRightHoverPiece
	}
	MiddleFrontRightHoverPiece.Parent = Body
	table.insert(HoverParts, MiddleFrontRightHoverPiece)
	local SmallMiddleFrontRightHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallMiddleFrontRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallMiddleFrontRightHoverPiece,
		C0 = CFrame.new(0.28, -0.425, -0.635) * CFrame.Angles(0, 0, 0),
		Parent = SmallMiddleFrontRightHoverPiece
	}
	SmallMiddleFrontRightHoverPiece.Parent = Body
	table.insert(HoverParts, SmallMiddleFrontRightHoverPiece)
	
	local FrontRightHoverPiece = BaseSmallHoverPiece2:Clone()
	local FrontRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = FrontRightHoverPiece,
		C0 = CFrame.new(0.28, -0.275, -1.5625) * CFrame.Angles(0, 0, 0),
		Parent = FrontRightHoverPiece
	}
	FrontRightHoverPiece.Parent = Body
	table.insert(HoverParts, FrontRightHoverPiece)
	local SmallFrontRightHoverPiece = BaseSmallHoverPiece1:Clone()
	local SmallFrontRightHoverPieceWeld = Create("Weld"){
		Part0 = Body,
		Part1 = SmallFrontRightHoverPiece,
		C0 = CFrame.new(0.28, -0.425, -1.5625) * CFrame.Angles(0, 0, 0),
		Parent = SmallFrontRightHoverPiece
	}
	SmallFrontRightHoverPiece.Parent = Body
	table.insert(HoverParts, SmallFrontRightHoverPiece)
	]]

	local Tables = {
		ExhaustSmoke = ExhaustSmoke,
		Lights = Lights,
		Sparkles = Sparkles,
		HoverParts = HoverParts,
	}
	
	return {
		Vehicle = Body,
		Tables = Tables
	}
	
end
--[[
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
]]

return {
	BaseUrl = BaseUrl,
--	MeshData = MeshData,
	CreateVehicle = CreateVehicle
}