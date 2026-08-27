--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

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


Module = require(191816425)

Grips = {
	Unequipped = CFrame.new(0.2, -1.15, 0, 8.07536562e-005, 0, -0.99999994, 0.00080632075, 0.999999702, 6.51133405e-008, 0.999999762, -0.000806320691, 8.07536198e-005),
	Equipped = CFrame.new(0, -1.15, 0, 0, 0, -1, 1, 8.05987838e-006, 0, 8.05987838e-006, -1, 0),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.25, Weight = nil, Speed = nil},
}

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

function DuplicateBoombox(MakeNew)
	Handle.Transparency = ((MakeNew and 1) or 0)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	for i, v in pairs({LeftArm, RightArm}) do
		local Boombox = Handle:Clone()
		Boombox.Name = "Boombox"
		Boombox.Transparency = 0
		Boombox.CanCollide = true
		local Weld = Create("Weld"){
			Part0 = v,
			Part1 = Boombox,
			C0 = (CFrame.new(0, 0, 0) * CFrame.Angles((math.pi / 2), math.pi, (-(math.pi / 2) * ((v == LeftArm and -1) or 1)))),
			C1 = Grips.Equipped,
		}
		if v == LeftArm then
			Weld.C1 = ((CFrame.new(Weld.C1.p * Vector3.new(-1, 1, 1)) * CFrame.Angles(Weld.C1:toEulerAnglesXYZ())) * CFrame.Angles(0, math.pi, 0))
		end
		Weld.Parent = Boombox
		Boombox.Parent = Tool
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Data = Module.GetTable({Key = "DualBoombox", Player = Player, Tool = Tool})
	if not Data then
		return
	end
	Functions = Data.GetData({Player = Player, Tool = Tool})
	if not Functions then
		return
	end
	Functions.SetUpBoombox()
	--Tool.Grip = Grips.Equipped
	ToolEquipped = true
	Spawn(function()
		DuplicateBoombox(true)
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
end

function Unequipped()
	--Tool.Grip = Grips.Unequipped
	Spawn(function()
		DuplicateBoombox(false)
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

ServerControl.OnServerInvoke = OnServerInvoke

if not ToolEquipped then
	DuplicateBoombox(false)
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)