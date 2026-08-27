--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PhoenixScript = script:WaitForChild("PhoenixScript")
RemoverScript = script:WaitForChild("RemoverScript")
MonitorScript = script:WaitForChild("MonitorScript")

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


BaseUrl = "http://wwww.roblox.com/asset/?id="

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

PhoenixDuration = (60 * 5)
SpawnDebounce = false

Objects = {
	LeftWing = Handle:WaitForChild("LeftWing"),
	RightWing = Handle:WaitForChild("RightWing"),
	LeftWeld = Handle:WaitForChild("LeftWingWeld"),
	RightWeld = Handle:WaitForChild("RightWingWeld"),
	Fire = Handle:WaitForChild("Fire")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Tool.Enabled = true

function ToggleVisibility(Parent, Visible)
	local Transparency = ((Visible and 0) or 1)
	local function SetTransparency(Parent)
		for i, v in pairs((type(Parent) == "table" and Parent) or Parent:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = Transparency
			elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") then
				v.Enabled = Visible
			end
			SetTransparency(v)
		end
	end
	SetTransparency(Parent)
	if Parent == Tool then
		Handle.Transparency = Transparency
		Handle.CanCollide = Visible
	end
end

function TrySpawnPhoenix()
	local CurrentPhoenixObject = Character:FindFirstChild("PhoenixRefObject")
	if CurrentPhoenixObject then
		if CurrentPhoenixObject.Value and CurrentPhoenixObject.Value.Parent then
			return
		else
			CurrentPhoenixObject:Destroy()
		end
	else
		CurrentPhoenix = Create("Model"){
			Name = "Phoenix",
		}
		local PhoenixBody = Handle:Clone()
		PhoenixBody.Name = "Torso"
		PhoenixBody.Parent = CurrentPhoenix
		local PhoenixRefObject = Create("ObjectValue"){
			Name = "PhoenixRefObject",
			Value = CurrentPhoenix,
			Parent = Character,
		}
		local MonitorScriptCopy = MonitorScript:Clone()
		MonitorScriptCopy.Disabled = false
		MonitorScriptCopy.Parent = PhoenixRefObject
		local Values = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
			{Name = "TargetPoint", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		}
		for i, v in pairs(Values) do
			local Value = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = CurrentPhoenix,
			}
		end
		for i, v in pairs({PhoenixScript, RemoverScript}) do
			local ScriptClone = v:Clone()
			ScriptClone.Disabled = false
			ScriptClone.Parent = CurrentPhoenix
		end
		ToggleVisibility(CurrentPhoenix, true)
		Debris:AddItem(CurrentPhoenix, PhoenixDuration)
		CurrentPhoenix.Parent = game:GetService("Workspace")
		return true
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if not SpawnDebounce and TrySpawnPhoenix() then
		ToggleVisibility(Tool, false)
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	MousePosition = MousePosition.Position
	local PhoenixRef = Character:FindFirstChild("PhoenixRefObject")
	if not PhoenixRef then
		return
	end
	local PhoenixModel = PhoenixRef.Value
	if PhoenixModel and PhoenixModel.Parent then
		local TargetPoint = PhoenixModel:FindFirstChild("TargetPoint")
		if not TargetPoint then
			return
		end
		TargetPoint.Value = MousePosition
	end
end 

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	for i, v in pairs({Objects.LeftWeld, Objects.RightWeld}) do
		if v then
			v.Parent = Handle
		end
	end
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		if not SpawnDebounce then
			SpawnDebounce = true
			ToggleVisibility(Tool, false)
			TrySpawnPhoenix()
			wait(0.5)
			SpawnDebounce = false
		end
	end)
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	ToggleVisibility(Tool, true)
	Handle.Transparency = 0
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

ToggleVisibility(Tool, true)

Tool.Equipped:connect(Equipped)
Tool.Activated:connect(Activated)
Tool.Unequipped:connect(Unequipped)