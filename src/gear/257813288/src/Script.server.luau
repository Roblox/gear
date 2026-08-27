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

--[[BaseEnchantmentCircle = BasePart:Clone()
BaseEnchantmentCircle.Name = "EnchantmentCircle"
BaseEnchantmentCircle.Transparency = 1
BaseEnchantmentCircle.Size = Vector3.new(9.8, 0.2, 9.8)
BaseEnchantmentCircle.CanCollide = false
for i, v in pairs({"Top", "Bottom"}) do
	local EnchantmentDecal = Create("Decal"){
		Name = "Decal",
		Transparency = 0,
		Texture = (BaseUrl .. "212259445"),
		Face = Enum.NormalId[v],
		Parent = BaseEnchantmentCircle,
	}
end]]

SpeedForParticle = 10

ReloadTime = 3

Sparkles = {}

Rate = (1 / 60)

MouseDown = false
ToolEquipped = false

Tool.Enabled = true

function SetUpCloak(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	ParticlePart = BasePart:Clone()
	ParticlePart.Name = "ParticlePart"
	ParticlePart.Transparency = 1
	ParticlePart.CanCollide = false
	ParticleWeld = Create("Weld"){
		Name = "Weld",
		Part0 = Torso,
		Part1 = ParticlePart,
		C0 = (CFrame.new(0, -3.5, 0) * CFrame.Angles((math.pi / 4), 0, 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = ParticlePart,
	}
	for i = 1, 5 do
		local Sparkle = Create("Sparkles"){
			Name = "Sparkles",
			Enabled = (Torso.Velocity.magnitude > SpeedForParticle),
			SparkleColor = Color3.new(math.random(), math.random(), math.random()),
			Parent = ParticlePart,
		}
		table.insert(Sparkles, Sparkle)
	end
	Cloak = Handle:Clone()
	Cloak.Name = "Cloak"
	Cloak.Transparency = 0
	Cloak.CanCollide = false
	CloakWeld = Create("Weld"){
		Name = "Weld",
		Part0 = Torso,
		Part1 = Cloak,
		C0 = ((CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0) + Vector3.new(1.5, 1.5, -1.5)) * CFrame.Angles((math.pi / 2), 0, 0)),
		C1 = Tool.Grip,
		Parent = Cloak,
	}
	for i, v in pairs({Cloak, ParticlePart}) do
		v.Parent = Tool
	end
	Spawn(function()
		while ParticlePart and ParticlePart.Parent and ToolEquipped and CheckIfAlive() do
			local Enabled = (Torso.Velocity.Magnitude > SpeedForParticle and Humanoid:GetState().Name == "Freefall")
			for i, v in pairs(Sparkles) do
				v.SparkleColor = Color3.new(math.random(-12, 22), math.random(-12, 22), math.random(-12, 22))
				v.Enabled = Enabled
			end
			wait(0.5)
		end
	end)
	--[[Spawn(function()
		EnchantmentCircle = BaseEnchantmentCircle:Clone()
		local SpinVelocity = Create("BodyAngularVelocity"){
			angularvelocity = Vector3.new(0, 1, 0),
			maxTorque = Vector3.new(0, math.huge, 0),
			Parent = EnchantmentCircle,
		}
		local SpinPosition = Create("BodyPosition"){
			maxForce = Vector3.new(math.huge, math.huge, math.huge),
			Parent = EnchantmentCircle,
		}
		EnchantmentCircle.CFrame = (Torso.CFrame * CFrame.new(0, -3, 0))
		SpinPosition.position = EnchantmentCircle.CFrame.p
		EnchantmentCircle.Parent = Tool
		local StartTime = tick()
		while EnchantmentCircle and EnchantmentCircle.Parent and ToolEquipped and CheckIfAlive() do
			if math.abs(Torso.Velocity.Y) < 15 and Humanoid:GetState().Name ~= "Freefall" then
				SpinPosition.position = (Torso.CFrame * CFrame.new(0, -3, 0)).p
			end
			wait(Rate)
		end
		if EnchantmentCircle and EnchantmentCircle.Parent then
			EnchantmentCircle:Destroy()
		end
	end)]]
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or MouseDown then
		return
	end
	MouseDown = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		SetUpCloak(true)
	end)
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	Sparkles = {}
	Spawn(function()
		SetUpCloak(false)
	end)
	Handle.Transparency = 0
	ToolEquipped = false
end

SetUpCloak(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)