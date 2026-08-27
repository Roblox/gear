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

Sounds = {
	CoilSound = Handle:WaitForChild("CoilSound"),
}

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

BaseEnchantmentCircle = BasePart:Clone()
BaseEnchantmentCircle.Name = "EnchantmentCircle"
BaseEnchantmentCircle.Transparency = 1
BaseEnchantmentCircle.Size = Vector3.new(9.8, 0.2, 9.8)
BaseEnchantmentCircle.CanCollide = false
for i, v in pairs({"Top", "Bottom"}) do
	local EnchantmentDecal = Create("Decal"){
		Name = "Decal",
		Transparency = 0,
		Texture = (BaseUrl .. "114029243"),
		Face = Enum.NormalId[v],
		Parent = BaseEnchantmentCircle,
	}
end

SpeedForSmoke = 10

ReloadTime = 3

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
	SmokePart = BasePart:Clone()
	SmokePart.Name = "SmokePart"
	SmokePart.Transparency = 1
	SmokePart.CanCollide = false
	SmokeWeld = Create("Weld"){
		Name = "Weld",
		Part0 = Torso,
		Part1 = SmokePart,
		C0 = (CFrame.new(0, -3.5, 0) * CFrame.Angles((math.pi / 4), 0, 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = SmokePart,
	}
	Smoke = Create("Smoke"){
		Name = "Smoke",
		Enabled = (Torso.Velocity.magnitude > SpeedForSmoke),
		RiseVelocity = 2,
		Opacity = 0.25,
		Color = Color3.new((26 / 255), (96 / 255), (182 / 255)),
		Size = 0.5,
		Parent = SmokePart,
	}
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
	for i, v in pairs({Cloak, SmokePart}) do
		v.Parent = Tool
	end
	Spawn(function()
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
		local BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, 0, math.huge),
			Parent = EnchantmentCircle,
			cframe = CFrame.new(0, 0, 0)
		}
		EnchantmentCircle.CFrame = (CFrame.new(Torso.Position) * CFrame.new(0, -3, 0))
		SpinPosition.position = EnchantmentCircle.CFrame.p
		EnchantmentCircle.Parent = Tool
		local StartTime = tick()
		while EnchantmentCircle and EnchantmentCircle.Parent and ToolEquipped and CheckIfAlive() do
			if math.abs(Torso.Velocity.Y) < 15 and Humanoid:GetState().Name ~= "Freefall" then
				SpinPosition.position = (Torso.CFrame * CFrame.new(0, -3, 0)).p
			end
			Smoke.Enabled = (Torso.Velocity.Magnitude > SpeedForSmoke)
			wait(Rate)
		end
		if EnchantmentCircle and EnchantmentCircle.Parent then
			EnchantmentCircle:Destroy()
		end
	end)
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
		Sounds.CoilSound:Play()
		Humanoid.WalkSpeed = (16 * 2)
		SetUpCloak(true)
		Handle.Transparency = 1
	end)
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
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