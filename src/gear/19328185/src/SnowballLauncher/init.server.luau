--Rescripted by Luckymaxer

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

ProjectileScript = script:WaitForChild("ProjectileScript")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Snowball = Handle:Clone()
Snowball.Transparency = 0

Velocity = 50

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Loaded = true
ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function IsTurbo()
	return Character:FindFirstChild("NinjaMaskOfAwesomeness")
end

function rndDir()
	return Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5)).Unit
end

function Fire(v)
	Handle.Transparency = 1
	Sounds.Fire:play()
	local launch = (Head.CFrame + v * 10)
	local missile = Snowball:Clone()
	missile.Name = "Projectile"
	missile.CFrame = launch
	missile.Velocity = v * 80
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,40,0)
	force.Parent = missile
	if IsTurbo() then
		missile.Velocity = v * 100
		force.force = Vector3.new(0,45,0)
	end
	
	local ProjectileScriptCopy = ProjectileScript:Clone()
	ProjectileScriptCopy.Disabled = false
	ProjectileScriptCopy.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = Player
	creator_tag.Name = "Creator"
	creator_tag.Parent = missile
	
	missile.Parent = game:GetService("Workspace")

end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	if Loaded then
		Loaded = false
		local TargetPos = MouseData.Position
		local lookAt = (TargetPos - Head.Position).unit
	
		Fire(lookAt)
		
		if IsTurbo() then
			wait(0.2)
			Fire(lookAt * 0.9 + rndDir() * 0.1)
			wait(0.1)
			Fire(lookAt * 0.8 + rndDir() * 0.2)
			wait(0.1)
		else
			wait(0.3)
		end
	else
		wait(0.1)
		Handle.Transparency = 0
		wait(0.1)
		Loaded = true
	end
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)