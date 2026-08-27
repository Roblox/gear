--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

CraftRickshaw = require(script:WaitForChild("CraftRickshaw"))

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
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
}

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

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

function CleanUp()
	for i, v in pairs({BodyGyro, Rickshaw}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
end

function MakeRickshaw()
	if not CheckIfAlive() or not ToolEquipped or not Tool.Enabled then
		return
	end
	CleanUp()
	Rickshaw = CraftRickshaw()
	if not Rickshaw then
		return
	end
	local Base = Rickshaw:FindFirstChild("Base")
	if Base then
		Base.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * -(Base.Size.Z * 1.5))
		local TorsoCF = Torso.CFrame
		BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, 0, math.huge),
			cframe = CFrame.new(0, 0, 0),
			D = 500,
			P = 3000,
			Parent = Torso,
		}
		local HoldOffset = -3.25
		local PersonWeld = Create("Weld"){
			Name = "AttachmentWeld",
			Part0 = Base,
			Part1 = Torso,
			C0 = (CFrame.new(0, 0, HoldOffset) * CFrame.Angles(0, 0, 0)),
			C1 = CFrame.new(0, 0, 0),
			Parent = Rickshaw,
		}
		local ToolValue = Create("ObjectValue"){
			Name = "Tool",
			Value = Tool,
			Parent = Rickshaw,
		}
		Rickshaw.Parent = game:GetService("Workspace")
		Torso.CFrame = ((TorsoCF - TorsoCF.lookVector * (HoldOffset * -1)) * CFrame.Angles(0, math.pi, 0))
	end
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
	Spawn(MakeRickshaw)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
end

function Unequipped()
	CleanUp()
	ToolEquipped = false
end

function ToggleToolVisibility()
	Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and 1) or 0)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

ToggleToolVisibility()

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		ToggleToolVisibility()
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)