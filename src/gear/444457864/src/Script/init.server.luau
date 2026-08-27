--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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

Particle = script:WaitForChild("Particle")
HitScript = script:WaitForChild("HitScript")

Grips = {
	Unequipped = Tool.Grip,
	Equipped = Tool.Grip,
}

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 0.5},
	Chop = {Animation = Tool:WaitForChild("Chop"), FadeTime = 0, Weight = nil, Speed = 1.25, Duration = 0.5},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Strike = Handle:WaitForChild("Strike"),
}

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

BaseOrb = BasePart:Clone()
BaseOrb.Name = "Projectile"
BaseOrb.Transparency = 0.2
BaseOrb.BrickColor = BrickColor.new("Pastel blue-green")
BaseOrb.Material = Enum.Material.Neon
BaseOrb.Size = Vector3.new(1, 1, 1)
BaseOrb.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.Sphere,
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseOrb,
}
ParticleEffect = Particle:Clone()
ParticleEffect.LockedToPart = false
ParticleEffect.Enabled = true
ParticleEffect.Parent = BaseOrb
StrikeSound = Sounds.Strike:Clone()
StrikeSound.Parent = BaseOrb

Gravity = 196.20
Rate = (1 / 60)

Shots = {Total = 6, Used = 0}
ShotReload = 10
FireRate = 0.125

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

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function Fire(TargetPosition)
	Shots.Used = (Shots.Used + 1)
	Delay(ShotReload, (function()
		Shots.Used = (Shots.Used - 1)
		if Shots.Used < Shots.Total then
			Tool.Enabled = true
		end
	end))
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local AttackAnimations = {Animations.Slash, Animations.Chop}
	local AnimationChosen = AttackAnimations[math.random(1, #AttackAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", AnimationChosen)
	end)
	wait(AnimationChosen.Duration / 2)
	if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
		return
	end
	local Projectile = BaseOrb:Clone()
	local SpawnPosition = (Handle.CFrame * CFrame.new(0, ((Handle.Size.Y / 2) - (Projectile.Size.Y / 2)), 0))
	local TargetDirection = CFrame.new(SpawnPosition.p, TargetPosition)
	local Speed = 110
	local Velocity = (TargetDirection.lookVector * Speed)
	local Mass = (Projectile:GetMass() * Gravity)
	local BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Projectile,
	}
	Projectile.Velocity = Velocity
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = math.random(25, 40)},
		{Name = "Radius", Class = "NumberValue", Value = 3.25},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile,
		}
	end
	local HitScriptCopy = HitScript:Clone()
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = Projectile
	Projectile.CFrame = SpawnPosition
	Debris:AddItem(Projectile, 5)
	local ParticleEffect = Projectile.Particle
	Delay(2.5, (function()
		ParticleEffect.Enabled = false
	end))
	Projectile.Parent = game:GetService("Workspace")
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() or not MouseData or not MouseData.Position or Shots.Used >= Shots.Total then
		return
	end
	Tool.Enabled = false
	local Sound = Sounds.Fire:Clone()
	Debris:AddItem(Sound, 1.25)
	Sound.Parent = Handle
	Sound:Play()
	Fire(MouseData.Position)
	wait(FireRate)
	if Shots.Used < Shots.Total then
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
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