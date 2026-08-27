--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

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


BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 8, Max = 8},
	Hit = {Min = 15, Max = 22},
	Dash = {Min = 17, Max = 24},
}

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

Sounds = {
	Hop = Handle:WaitForChild("Hop"),
}

Animations = {
	Grip = {Animation = Tool:WaitForChild("Grip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Grips = {
	Unequipped = CFrame.new(1.5, 1.6, -0.05, 1, 4.24252758e-005, -0, -4.24252758e-005, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(1.5, 1.5, -0.1, 1, 0, 0, -0, 0.661191463, 0.750217259, 0, -0.750217259, 0.661191463),
}

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Handle.Transparency = 0
Tool.Enabled = true

function EnableHop(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs(Handle:GetChildren()) do
		if string.find(string.lower(v.ClassName), string.lower("Body")) then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	Handle.CanCollide = true
	--[[FakeHandle = BasePart:Clone()
	FakeHandle.Name = "FakeHandle"
	FakeHandle.Transparency = 1
	FakeHandle.Size = Handle.Size
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = Handle,
		Part1 = FakeHandle,
		Parent = FakeHandle,
	}]]
	local BodyGyro = Create("BodyGyro"){
		Name = "BodyGyro",
		D = 500,
		P = 3000,
		maxTorque = Vector3.new(math.huge, 0, math.huge),
		Parent = Handle, --FakeHandle,
	}
	--FakeHandle.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Spawn(function()
		EnableHop(true)
		InvokeClient("PlayAnimation", Animations.Grip)
	end)
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	Spawn(function()
		EnableHop(false)
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	EnableHop(false)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)