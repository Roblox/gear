--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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


RobotHead = Handle:Clone()
RobotHead.Name = "RobotHead"
RobotHead.Transparency = 0
RobotHead.CanCollide = false

Hats = {}

ReloadTime = 0

LightEnabled = false

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CreateRobotHead(MakeNew)
	Handle.Transparency = ((MakeNew and 1) or 0)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if CheckIfAlive() then
		Head.Transparency = Handle.Transparency
	end
	if not MakeNew or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local HeadOffset = CFrame.new(0, 0.4, 0)
	RobotHeadCopy = RobotHead:Clone()
	RobotHeadCopy.CFrame = (Head.CFrame * HeadOffset)
	local Motor = Create("Motor6D"){
		Name = "Motor",
		Part0 = Head,
		Part1 = RobotHeadCopy,
		C0 = (HeadOffset * CFrame.Angles(-(math.pi / 2), 0, 0)),
		C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		DesiredAngle = 9999999999,
		CurrentAngle = 0,
		MaxVelocity = 0.0375,
		Parent = RobotHeadCopy,
	}
	Light = Create("SpotLight"){
		Name = "Light",
		Color = Color3.new((85 / 255), (255 / 255), (255 / 255)),
		Angle = 45,
		Brightness = 50,
		Range = 16,
		Face = Enum.NormalId.Front,
		Shadows = false,
		Enabled = LightEnabled,
		Parent = RobotHeadCopy,
	}
	RobotHeadCopy.Parent = Tool
end

function Activated()
	if not Tool.Enabled or not Light then
		return
	end
	Tool.Enabled = false
	LightEnabled = not LightEnabled
	Light.Enabled = LightEnabled
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
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Hat") then
			table.insert(Hats, v)
			v.Parent = nil
		end
	end
	ToolEquipped = true
	Spawn(function()
		CreateRobotHead(true)
	end)
end

function Unequipped()
	CreateRobotHead(false)
	if CheckIfAlive() then
		for i, v in pairs(Hats) do
			v.Parent = Character
		end
	end
	Hats = {}
	ToolEquipped = false
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateRobotHead(false)
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)