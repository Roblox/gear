--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Particles = script:WaitForChild("Particles")
PoisonScript = script:WaitForChild("PoisonScript")
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


BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Grips = {
	Equipped = CFrame.new(0.3, -0.35, 1.25, 0.714072824, -0, 0.700071454, 0, 1, 0, -0.700071394, 0, 0.714072883),
	Unequipped = CFrame.new(0, -0.5, 1.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Charge = Handle:WaitForChild("Charge"),
	Fire = Handle:WaitForChild("Fire"),
}

Rate = (1 / 60)

FiringOffset = Vector3.new(2, 0.3, -1.5)

MouseDown = false
ToolEquipped = false

Configuration = {
	Accuracy = Vector3.new(0.1, 0.1, 0.1),
	Damage = {Min = 20, Max = 65},
	FireRate = 1.5,
	Range = 125,
	FadeRate = 1.25,
	MaxCharge = 2,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function LaserTouched(Hit, Position)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Accessory") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	local DeterminedDamage = ChargeDamage
	local HealthAfter = (humanoid.Health - DeterminedDamage)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DeterminedDamage)
	if HealthAfter <= 0 then
		local AshColors = {"Really black", "Black", "Dark stone grey", "White"}
		for i = 1, math.random(25, 50) do
			local Ashes = BasePart:Clone()
			Ashes.Name = "Ashes"
			Ashes.BrickColor = BrickColor.new(AshColors[math.random(1, #AshColors)])
			Ashes.Material = Enum.Material.Granite
			Ashes.Size = Vector3.new(0.5, 0.2, 0.5)
			Ashes.CFrame = (CFrame.new(torso.Position) * CFrame.new((math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001)) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
			Debris:AddItem(Ashes, math.random(3, 5))
			Ashes.Parent = game:GetService("Workspace")
		end
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") or v:IsA("Accessory") then
				v:Destroy()
			end
		end
	elseif ChargePercentageToDecimal >= 1 then
		local PoisonScriptCopy = character:FindFirstChild(PoisonScript.Name)
		if not PoisonScriptCopy then
			PoisonScriptCopy = PoisonScript:Clone()
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = 20},
				{Name = "Duration", Class = "NumberValue", Value = 5},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = PoisonScriptCopy,
				}
			end
			PoisonScriptCopy.Disabled = false
			PoisonScriptCopy.Parent = character
		end
	end
end

function FireLaser(StartPosition, TargetPosition)
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	local RayHit, RayPos, RayNormal = Functions.CastRay(StartPosition, Direction, Configuration.Range, {Character}, false)
	local RayLength = (StartPosition - RayPos).Magnitude
	Direction = CFrame.new(StartPosition, RayPos)
	local Laser = BasePart:Clone()
	local FadeDuration = Configuration.FadeRate
	local FadeRate = 10
	local Laser = BasePart:Clone()
	for i, v in pairs(Particles:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			for ii = 1, 5 do
				local NewParticle = v:Clone()
				NewParticle.Enabled = true
				NewParticle.Parent = Laser
			end
		end
	end
	Laser.Name = "Laser"
	Laser.Transparency = 1
	Laser.Size = Vector3.new(1, RayLength, 1)
	Laser.CFrame = (Direction * CFrame.new(0, 0, -(RayLength / 2)) * CFrame.Angles((math.pi / 2), 0, 0))
	Laser.Anchored = true
	Laser.CanCollide = false
	Debris:AddItem(Laser, FadeDuration)
	Laser.Parent = game:GetService("Workspace")
	LaserTouched(RayHit, RayPos)
end

function Fire()
	Tool.Enabled = false
	local TickTime = (tick() - ChargeTick)
	ChargePercentage = Functions.Clamp(Functions.GetPercentage(0, Configuration.MaxCharge, (tick() - ChargeTick)), 0, 100)
	ChargePercentageToDecimal = (ChargePercentage * 0.01)
	ChargeDamage = Functions.Clamp((Configuration.Damage.Max * ChargePercentageToDecimal), Configuration.Damage.Min, Configuration.Damage.Max)
	local FireSound = Sounds.Fire:Clone()
	Debris:AddItem(FireSound, 1.25)
	FireSound.Parent = Handle
	FireSound:Play()
	local StartPosition = (Handle.CFrame * CFrame.new(FiringOffset.X, FiringOffset.Y, FiringOffset.Z)).p
	local TargetPosition = InvokeClient("MousePosition")
	if not TargetPosition then
		Tool.Enabled = true
		return
	end
	TargetPosition = TargetPosition.Position
	local Accuracy = (Configuration.Accuracy * 100)
	TargetPosition = TargetPosition + Vector3.new((math.random(-Accuracy.X, Accuracy.X) * 0.01), (math.random(-Accuracy.Y, Accuracy.Y) * 0.01), (math.random(-Accuracy.Z, Accuracy.Z) * 0.01))
	FireLaser(StartPosition, TargetPosition)
	wait(Configuration.FireRate)
	Tool.Enabled = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or MouseDown then
		return
	end
	MouseDown = true
	Sounds.Charge:Play()
	ChargeTick = tick()
	while (tick() - ChargeTick) < Configuration.MaxCharge and MouseDown do
		wait(Rate)
	end
	Sounds.Charge:Stop()
	MouseDown = false
	Fire()
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local Animation = Animations.Hold 
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Hold
		end
		InvokeClient("PlayAnimation", Animation)
	end)
	for i, v in pairs({"Left Arm", "Right Arm", "LeftHand", "LeftUpperArm", "LeftLowerArm", "RightHand", "RightLowerArm", "RightUpperArm"}) do
		local Arm = Character:FindFirstChild(v)
		if Arm then
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
			end)
		end
	end
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	MouseDown = false
	Tool.Grip = Grips.Unequipped
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
	if Mode == "Button1Click" then
		local Down = Value.Down
		MouseDown = Down
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)