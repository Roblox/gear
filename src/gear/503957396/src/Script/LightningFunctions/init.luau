--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


LightningModelRemoval = script:WaitForChild("LightningModelRemoval")

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

BaseLightning = BasePart:Clone()
BaseLightning.Name = "Effect"
BaseLightning.Transparency = 0.1
BaseLightning.Material = Enum.Material.Neon
BaseLightning.Anchored = true
BaseLightning.CanCollide = false

Rate = 0.05

LightningBolts = {}
LastBolt = nil

function GetLightningModel()
	local LightningModelName = "LightningModel"
	local LightningModel = game:GetService("Workspace"):FindFirstChild(LightningModelName)
	if not LightningModel then
		LightningModel = Create("Model"){
			Name = LightningModelName,
		}
		local LightningModelRemovalClone = LightningModelRemoval:Clone()
		LightningModelRemovalClone.Disabled = false
		LightningModelRemovalClone.Parent = LightningModel
		LightningModel.Parent = game:GetService("Workspace")
	end
	return LightningModel
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Lightning", "Bullet"}
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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function Zap(Table)
	local StartPos, TargetPos, Character, Color = Table.StartPosition, Table.TargetPosition, Table.Character, Table.Color
	local Duration = (Table.Duration or 2)
	local FadeRate = (Table.FadeRate or 0.05)
	local Individualize = (Table.Individualize or false)
	local MaxRange = (Table.MaxRange or 40)
	local SegmentLength = (Table.SegmentLength or 5)
	local TimeToFade = (Table.TimeToFade or 0.5)
	local Ignore = (Table.Ignore or {})
	local Thickness = (Table.Thickness or 0.4)
	if not StartPos or not TargetPos or not Character then
		return
	end
	local LightningModel = GetLightningModel()
	for i, v in pairs({Character, LightningModel}) do
		table.insert(Ignore, v)
	end
	local LastPos = StartPos
	local Direction = CFrame.new(StartPos, TargetPos).lookVector
	local RayHit, RayPos, RayNormal = CastRay(StartPos, Direction, MaxRange, Ignore, false)
	local RayLength = (StartPos - RayPos).Magnitude
	local Struck = false
	local TotalSegments = math.ceil(RayLength / SegmentLength)
	Direction = CFrame.new(StartPos, RayPos).lookVector
	local LightningBolt = Create("Model"){
		Name = "LightningBolt",
	}
	if not Individualize then
		table.insert(LightningBolts, LightningBolt)
	end
	LastBolt = LightningBolt
	Debris:AddItem(LightningBolt, Duration)
	LightningBolt.Parent = LightningModel
	for i = 1, TotalSegments do
		if not Struck then
			local Entropy = Vector3.new(((math.random() * 0.125) - 0), ((math.random() * 0.25) - 0), 0) --Vector3.new(((math.random() * 2) - 1), ((math.random() * 2) - 1), ((math.random() * 2) - 1))
			local NewPos = (StartPos + (Direction * (RayLength * (i / TotalSegments))) + Entropy)
			local SegmentVec = (NewPos - LastPos)
			local RayHit, RayPos, RayNormal = CastRay(LastPos, SegmentVec.Unit, SegmentVec.Magnitude, {Character, LightningModel}, false) 
			local RayVec = (LastPos - RayPos)
			local LightningPart = BaseLightning:Clone()
			LightningPart.BrickColor = BrickColor.new(Color)
			LightningPart.Size = Vector3.new(0.2, 0.2, RayVec.Magnitude)
			LightningPart.CFrame = (CFrame.new(LastPos, RayPos) * CFrame.new(0, 0, -(RayVec.Magnitude / 2)))
			Debris:AddItem(LightningPart, (Duration - 0.5))
			local Light = Create("PointLight"){
				Name = "Light",
				Color = BrickColor.new(Color).Color,
				Brightness = 50,
				Range = 2,
				Shadows = false,
				Enabled = true,
				Parent = LightningPart,
			}
			--Make circular
			local CylinderMesh = Create("CylinderMesh"){
				Name = "Mesh",
				Scale = Vector3.new(Thickness, 1, Thickness),
				Parent = LightningPart,
			}
			local OrigCF = LightningPart.CFrame
			LightningPart.Size = Vector3.new(LightningPart.Size.X, LightningPart.Size.Z, LightningPart.Size.Y)
			LightningPart.CFrame = (OrigCF * CFrame.Angles((math.pi / 2), 0, 0))
			LightningPart.Parent = LightningBolt
			LastPos = NewPos
			Spawn(function()
				local FadeRate = 0.05
				local OrigTransparency = LightningPart.Transparency
				for i = 1, (TimeToFade / FadeRate) do
					wait(FadeRate)
					LightningPart.Transparency = (OrigTransparency + (i / (TimeToFade / FadeRate)))
					for ii, vv in pairs(LightningPart:GetChildren()) do
						if vv:IsA("Light") then
							vv.Brightness = (50 - (50 * (GetPercentage(0, 1, LightningPart.Transparency) * 0.01)))
							if vv.Brightness <= 0 then
								vv.Enabled = false
							end
						end
					end
				end
			end)
		end
	end
	return {RayHit = RayHit, RayPos = RayPos, RayNormal = RayNormal, LightningModel = LightningModel}
end

function RemoveLightning()
	for i, v in pairs(LightningBolts) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	LightningBolts = {}
end

Functions = {
	Zap = Zap,
	RemoveLightning = RemoveLightning,
}

return Functions