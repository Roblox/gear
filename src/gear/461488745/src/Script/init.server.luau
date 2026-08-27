--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Particles = Handle:WaitForChild("Particles")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

FireParticles = script:WaitForChild("Particles")

HitScript = script:WaitForChild("HitScript")

Functions = require(script:WaitForChild("Functions"))

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

Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

Animations = {
	Cast = {Animation = Tool:WaitForChild("Cast"), FadeTime = nil, Weight = nil, Speed = 3.5, Duration = 0.25},
}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

ReloadTime = 1

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
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
	local Animation = Animations.Cast
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration / 1)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not ToolEquipped or not CurrentlyEquipped then
		Tool.Enabled = true
		return
	end
	Sounds.Fire:Play()
	local Fireball = BasePart:Clone()
	Fireball.Name = "Projectile"
	Fireball.Transparency = 0.9
	Fireball.BrickColor = BrickColor.new("Deep orange")
	Fireball.Material = Enum.Material.SmoothPlastic
	Fireball.Shape = Enum.PartType.Ball
	Fireball.Size = Vector3.new(2, 2, 2)
	Fireball.CanCollide = false
	for i = 1, 10 do
		local Fire = FireParticles:Clone()
		Fire.LockedToPart = false
		Fire.Enabled = true
		Fire.Parent = Fireball
	end
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = math.random(25, 45)},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Fireball,
		}
	end
	local HitScriptCopy = HitScript:Clone()
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = Fireball
	local MousePos = MouseData.Position
	local Direction = CFrame.new(Handle.Position, MousePos).lookVector
	local Gravity = 196.20
	local Weight = (Fireball:GetMass() * Gravity)
	local Speed = 125
	local Velocity = (Direction * Speed)
	local BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		maxForce = Vector3.new(Weight, Weight, Weight),
		velocity = Velocity,
		Parent = Fireball,
	}
	Fireball.Velocity = Velocity
	Fireball.CFrame = Handle.CFrame
	Debris:AddItem(Fireball, 5)
	Fireball.Parent = game:GetService("Workspace")
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
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

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)