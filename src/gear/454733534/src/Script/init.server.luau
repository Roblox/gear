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


BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.5, Weight = nil, Speed = nil, Duration = 0.25},
}

Grips = {
	Default = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1),
	Equip = CFrame.new(0.5, 0.75, 0.600000024, 0.824145317, 0, 0.566378534, 0.328423709, 0.814711809, -0.477893829, -0.461435348, 0.579866052, 0.67144078),
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
Tool.Grip = Grips.Default
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.Hold
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
		Tool.Grip = Grips.Equip
		wait(1)
		if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
			for i = 1, 500 do
				if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
					return
				end
				local Offset = (Torso.Position + Vector3.new(0, 5, 0))
				local Radius = 100
				Radius = (Radius * 1000)
				local RandomOffset = (Offset + (Vector3.new(math.random(-Radius, Radius), 0, math.random(-Radius, Radius)) * 0.001))
				local RayHit, RayPos, RayNormal, RaySurface = Functions.CastRay(RandomOffset, Vector3.new(0, -1, 0), (Torso.Size.Y * 10), {Character})
				if RayHit then
					Torso.CFrame = ((CFrame.new(RayPos) + Vector3.new(0, (Torso.Size.Y * 1), 0)) * CFrame.Angles(Torso.CFrame:toEulerAnglesXYZ()))
					break
				end
			end
			wait(1)
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				Tool.Grip = Grips.Default
				Spawn(function()
					InvokeClient("StopAnimation", Animation)
				end)
			end
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	wait(2)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Default
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)