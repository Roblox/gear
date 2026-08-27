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

ReloadTime = 0

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function SetFlame()
	if FireDisplay then
		FireDisplay:disconnect()
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	FlamePart = BasePart:Clone()
	FlamePart.Name = "Flame"
	FlamePart.Transparency = 1
	FlamePart.CanCollide = false
	Light = Create("PointLight"){
		Name = "Light",
		Color = Color3.new((255 / 255), (255 / 255), (0 / 255)),
		Brightness = 50,
		Range = 5,
		Shadows = false,
		Enabled = false,
		Parent = FlamePart,
	}
	local Weld = Create("Weld"){
		Part0 = Handle,
		Part1 = FlamePart,
		C0 = CFrame.new(0, 2.5, 0),
		C1 = CFrame.new(0, 0, 0),
		Parent = FlamePart,
	}
	FlamePart.Parent = Tool
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	if Light then
		Light.Enabled = not Light.Enabled
		if FireDisplay then
			FireDisplay:disconnect()
		end
		if Light.Enabled then
			Spawn(function()
				local FlamePieces = {}
				local LastFire = tick()
				FireDisplay = RunService.Stepped:connect(function(Time, Step)
					local Now = tick()
					if not Light.Enabled or (Now - LastFire) >= 0.2 then
						return
					end
					LastFire = Now
					local Colors = {"Bright orange", "Bright yellow", "Bright red"}
					local Size = (math.random(10, 80) * 0.01)
					local Flame = BasePart:Clone()
					Flame.Name = "Effect"
					Flame.Transparency = (math.random(15, 50) * 0.01)
					Flame.BrickColor = BrickColor.new(Colors[math.random(1, #Colors)])
					Flame.Material = Enum.Material.Plastic
					Flame.TopSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.RightSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.BackSurface = Enum.SurfaceType.SmoothNoOutlines
					Flame.Size = Vector3.new(Size, Size, Size)
					Flame.CanCollide = false
					local FlameWeld = Create("Weld"){
						Part0 = FlamePart,
						Part1 = Flame,
						C0 = (CFrame.new(0, 0, 0) + (CFrame.new(0, 0, 0) * CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))).lookVector * (math.random(1, 300) * 0.001)),
						C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(math.random(), math.random(), math.random())),
						Parent = Flame,
					}
					table.insert(FlamePieces, Flame)
					Debris:AddItem(Flame, (math.random() * 1.5))
					for i, v in pairs(FlamePieces) do
						v.Transparency = (v.Transparency + 0.05)
						if v.Transparency >= 1 then
							table.remove(FlamePieces, i)
							if v and v.Parent then
								v:Destroy()
							end
						end
					end
					Flame.Parent = Tool
				end)
			end)
		else
			for i, v in pairs(Tool:GetChildren()) do
				if v:IsA("BasePart") and v ~= Handle and v ~= FlamePart then
					v:Destroy()
				end
			end
		end
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Delay(0, (function()
	SetFlame()
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)