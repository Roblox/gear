--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

NPCModule = require(191816425)

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

Grips = {
	Display = CFrame.new(0.75, -1.75, 4, 0, 0, -1, 0, 1, 0, 1, -0, 0),
	Equipped = CFrame.new(0, -1.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

ReloadTime = 1

ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Grip = Grips.Equipped
Tool.Enabled = true

function MakeNPC()
	local Data = NPCModule.GetTable({Key = "DaVinciScrew", Player = Player})
	if not Data then
		return
	end
	local NPCData = Data.GetData({Player = Player, Tool = Tool})
	if PlayerNPC and PlayerNPC.Parent then
		PlayerNPC:Destroy()
	end
	PlayerNPC = NPCData.MakeNPC()
	NPCData.InsertNPC()
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	if Tool.Enabled then
		Spawn(function()
			MakeNPC()
		end)
	end
	ToolEquipped = true
end

function Unequipped()
	if PlayerNPC then
		for i, v in pairs({PlayerNPC}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		PlayerNPC = nil
		Spawn(function()
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			if not ToolEquipped then
				Handle.Transparency = 0
			end
		end)
	end
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Enabled" and Tool.Enabled and ToolEquipped and Tool.Parent then
		MakeNPC()
	elseif Property == "Parent" and Tool.Parent and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		Handle.Transparency = 0
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)