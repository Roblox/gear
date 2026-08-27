--Made by Luckymaxer

Part = script.Parent
Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

GearModule = require(236215724)
SwapGear = GearModule.SwapGear

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


Creator = Part:FindFirstChild("Creator")

StickTime = 3

Size = {
	Min = {
		Size = Vector3.new(0.75, 1.25, 0.75),
		Scale = Vector3.new(1, 1, 1)
	},
	Max = {
		Size = Vector3.new(2.25, 3.75, 2.25),
		Scale = Vector3.new(3.25, 3.25, 3.25)
	}
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

Rate = (1 / 60)
ProjectileNames = {"GearRecycler"}
Grounded = false

Part.Size = Size.Min.Size
Mesh.Scale = Size.Min.Scale

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool") or Hit.Parent:FindFirstChild("Humanoid") then
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

function IsFlipped(Object)
	local Vector1 = Object.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > ((math.pi / 4) + 0.01))
end

function Stick(Hit)
	if Grounded then
		return
	end
	Grounded = true
	Part.Velocity = Vector3.new(0, 0, 0)
	Part.RotVelocity = Vector3.new(0, 0, 0)
	local Weld
	local WeldData = {}
	if Hit and Hit.Object and Hit.Object.Parent and Hit.RayData then
		local OriginalCFrame = Part.CFrame
		local AngleX, AngleY, AngleZ = Part.CFrame:toEulerAnglesXYZ()
		local PartCFrame = CFrame.new(OriginalCFrame.p, (OriginalCFrame + Hit.RayData.RayNormal * 2).p) * CFrame.Angles(-(math.pi / 2), 0, 0)
		local BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, 0, math.huge),
			cframe = PartCFrame,
			Parent = Part,
		}
		local BodyPosition = Create("BodyPosition"){
			maxForce = Vector3.new(math.huge, 0, math.huge),
			position = OriginalCFrame.p,
			Parent = Part,
		}
		local BodyVelocity = Create("BodyVelocity"){
			maxForce = Vector3.new(0, math.huge, 0),
			velocity = Vector3.new(0, -10, 0),
			Parent = Part,
		}
	end
	Part.Velocity = Vector3.new(0, 0, 0)
	Part.RotVelocity = Vector3.new(0, 0, 0)
	local Frames = 10
	for i = 1, Frames do
		local Increase = (1 / Frames)
		local OriginalCFrame = Part.CFrame
		Part.Size = ((Size.Max.Size / Frames) * i)
		Part.Mesh.Scale = ((Size.Max.Scale / Frames) * i)
		Part.CFrame = OriginalCFrame * CFrame.new(0, (Size.Max.Size.Y / Frames), 0)
		wait(Rate)
	end
	local TextDisplay = BasePart:Clone()
	TextDisplay.Name = "Part"
	TextDisplay.Transparency = 1
	TextDisplay.Size = Vector3.new(1.5, 0.2, 2.5)
	TextDisplay.CanCollide = false
	local SurfaceGui = Create("SurfaceGui"){
		Name = "InteractiveGui",
		Face = Enum.NormalId.Top,
		Enabled = true,
		Active = true,
		Create("TextLabel"){
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Font = Enum.Font.Legacy,
			FontSize = Enum.FontSize.Size48,
			TextColor3 = BrickColor.new("Institutional white").Color,
			TextScaled = true,
			TextWrapped = true,
			Text = "Insert Gear Here",
			Active = true,
			Parent = SurfaceGui,
		}
	}
	SurfaceGui.Parent = TextDisplay
	local Weld = Create("Weld"){
		Part0 = Part,
		Part1 = TextDisplay,
		C0 = CFrame.new(0.5, 1.325, 0) * CFrame.Angles(0, 0, -(math.pi / 4)),
		Parent = TextDisplay,
	}
	TextDisplay.Parent = Part
	local Tick = tostring(tick())
	TextDisplay.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or IsFlipped(Part) then
			return
		end
		local tool = Hit.Parent
		if not tool:IsA("Tool") then
			return
		end
		local NotRecyclable = tool:FindFirstChild("NotRecyclable")
		if NotRecyclable or tool.Name == "GearRecycler" then
			return
		end
		local RecycledGear = tool:FindFirstChild("RecycledGear")
		if RecycledGear and RecycledGear.Value == Tick then
			return
		end
		local character = tool.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			local NewGear = SwapGear({Player = player, Gear = tool, Equip = true})
			RecycledGear = Create("StringValue"){
				Name = "RecycledGear",
				Value = Tick,
				Parent = NewGear,
			}
		end
	end)
end

function StickTouched(Part)
	local PartTouched
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Grounded then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local humanoid = character:FindFirstChild("Humanoid")
		if player or humanoid then
			return
		end
		--[[if not Hit:IsGrounded() then
			return
		end]]
		local RayHit, RayPos, RayNormal = CastRay(Part.Position, CFrame.new(Part.Position, (Part.CFrame * CFrame.new(0, -1, 0)).p).lookVector, ((Part.Size.Y / 2) + 0.5), {Part}, false)
		if RayHit then
			Spawn(function()
				Stick({Object = Hit, RayData = {RayPos = RayPos, RayNormal = RayNormal}})
			end)
			if PartTouched then
				PartTouched:disconnect()
			end
		end
	end)
	wait(StickTime)
	if PartTouched then
		PartTouched:disconnect()
	end
	if not Grounded then
		Spawn(function()
			Stick()
		end)
	end
end

StickTouched(Part)

Spawn(function()
	local StickTick = tick()
	while (tick() - StickTick) < StickTime and not Grounded do
		wait(Rate)
	end
end)