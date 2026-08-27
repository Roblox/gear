--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

InvisibilityScript = script:WaitForChild("InvisibilityScript")

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


Animations = {
	Drink = {Animation = Tool:WaitForChild("Drink"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.5},
}

Duration = 20
ReloadTime = 5

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local InvisibilityScriptCopy = Character:FindFirstChild(InvisibilityScript.Name)
	local Invisible = Character:FindFirstChild("Invisible")
	if InvisibilityScriptCopy or Invisible then
		return
	end
	Tool.Enabled = false
	Invisible = Create("BoolValue"){
		Name = "Invisible",
		Value = true,
	}
	Debris:AddItem(Invisible, (Duration + 2))
	Invisible.Parent = Character
	for i, v in pairs({ToolUnequipped2}) do
		if v then
			v:disconnect()
		end
	end
	local CurrentlyEquipped = true
	ToolUnequipped2 = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.Drink
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	if CurrentlyEquipped then
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
			{Name = "Invisible", Class = "BoolValue", Value = false},
			{Name = "Duration", Class = "NumberValue", Value = Duration},
		}
		InvisibilityScriptCopy = InvisibilityScript:Clone()
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = InvisibilityScriptCopy,
			}
		end
		InvisibilityScriptCopy.Disabled = false
		InvisibilityScriptCopy.Parent = Character
		InvisibilityScriptCopy.Invisible.Value = true
		wait(Duration)
		for i, v in pairs({ToolUnequipped2}) do
			if v then
				v:disconnect()
			end
		end
	end
	if ToolUnequipped2 then
		ToolUnequipped2:disconnect()
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped2}) do
		if v then
			v:disconnect()
		end
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)