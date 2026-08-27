--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
ContentProvider = game:GetService("ContentProvider")

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


Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

ToolEquipped = false

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function DisableJump(Boolean)
	if JumpDisabled then
		JumpDisabled:disconnect()
	end
	if not Boolean then
		return
	end
	JumpDisabled = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" and Humanoid.Jump then
			Humanoid.Jump = false
		end
	end)
end

function KeyPressed(Key, Down)
	Spawn(function()
		InvokeServer("KeyPress", {Key = Key, Down = Down})
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	PlayerMouse.KeyDown:connect(function(Key)
		KeyPressed(Key, true)
	end)
	PlayerMouse.KeyUp:connect(function(Key)
		KeyPressed(Key, false)
	end)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("Animation") then
			ContentProvider:Preload(v.AnimationId)
		end
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({JumpDisabled, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	LocalObjects = {}
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" and value then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "DisableJump" and value then
		local Disabled = value.Disabled
		DisableJump(Disabled)
	elseif mode == "MouseData" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
	elseif mode == "SetLocalTransparencyModifier" and value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							if ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)