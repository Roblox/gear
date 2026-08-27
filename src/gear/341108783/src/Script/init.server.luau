--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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

Functions = require(script:WaitForChild("Functions"))

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75},
}

Sounds = {
	Throw = Handle:WaitForChild("Throw"),
	Clash = Handle:WaitForChild("Clash"),
	Clink = Handle:WaitForChild("Clink"),
}

StarsReady = {}
Projectiles = {}

Gravity = 196.20
Rate = (1 / 60)
ReloadTime = 1.5
Damage = 15

Kunais = {}
LastAttack = 0
Loaded = false
Throwing = false
SwitchEvenOddParity = -1

ManagingProjectiles = false
ToolEquipped = false

BaseKunai = Handle:Clone()
BaseKunai.Name = "Projectile"
BaseKunai.Transparency = 0
BaseKunai.CanCollide = true

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Enabled = true

function Throw(Kunai, SpawnPos, TargetPos)
	local ThrowDirection = CFrame.Angles(0, Kunai.Angle, 0) * (TargetPos - Handle.Position).Unit--CFrame.new(SpawnPos, TargetPos)
	local MoveDirection = (CFrame.new(SpawnPos, SpawnPos + ThrowDirection) * CFrame.Angles(0, -(math.pi / 2), (math.pi / 2)))
	local Force = 30
	local Velocity = (ThrowDirection * Force)
	local Mass = (Kunai.Part:GetMass() * Gravity)
	local BodyVelocity = Create("BodyForce"){
		force = Vector3.new(0, Mass, 0),
		Parent = Kunai.Part,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = MoveDirection,
		Parent = Kunai.Part,
	}
	Debris:AddItem(Kunai.Part, 10)
	Kunai.Part.CanCollide = false
	Kunai.Part.Parent = game:GetService("Workspace")
	for i, v in pairs(Kunai.Part:GetChildren()) do
		if v:IsA("JointInstance") then
			v:Destroy()
		end
	end
	SpawnPos = SpawnPos + ThrowDirection * 1
	Kunai.Part.CFrame = MoveDirection
	Kunai.Part.Velocity = Velocity
	Spawn(function()
		local KunaiStick
		KunaiStick = RunService.Stepped:connect(function(Step)
			FlyProjectile(Kunai.Part)
		end)
		Kunai.Part.Changed:connect(function(Property)
			if Property == "Parent" and not Kunai.Part.Parent then
				if KunaiStick then
					KunaiStick:disconnect()
				end
			end
		end)
	end)
	Kunai.Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		FlyProjectile(Kunai.Part, Hit)
	end)
end

function NewKunai()
	local Kunai = BaseKunai:Clone()
	local KunaiWeld = Create("Weld"){
		Name = "Weld",
		Part0 = Kunai,
		Part1 = Handle,
		C0 = CFrame.new(0, 0, 0),
		Parent = Kunai,
	}
	return Kunai
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	local Now = tick()
	if not Loaded then
		Kunais = {}
		local Kunai = NewKunai()
		Kunai.Weld.C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0) + Vector3.new(0, 0, 0))
		table.insert(Kunais, {Part = Kunai, Index = (#Kunais + 1), Angle = 0})
		Kunai.Parent = Tool
		LastAttack = Now
		Loaded = true
	elseif (Now - LastAttack) < 0.70 and #Kunais < 5 then
		Sounds.Clink:Play()
		local Angle = (math.ceil(#Kunais / 2) * math.pi / 8 * SwitchEvenOddParity)
		SwitchEvenOddParity = -SwitchEvenOddParity
		local Kunai = NewKunai()
		Kunai.Weld.C1 = (CFrame.new(0.5, -0.5, 0) * CFrame.Angles(0, 0, Angle) + Vector3.new((-0.75 * math.sin(Angle) - 0.5), (0.65 * math.cos(Angle) - 0.25), 0))
		table.insert(Kunais, {Part = Kunai, Index = (#Kunais + 1), Angle = Angle})
		Kunai.Parent = Tool
		Loaded = true
	elseif (Now - LastAttack) > 1.45 then
		local MouseData = InvokeClient("MouseData")
		if not ToolEquipped or not CheckIfAlive() or Throwing or not MouseData or not MouseData.Position then
			return
		end
		Throwing = true
		Sounds.Throw:Play()
		Spawn(function()
			if Humanoid then
				if Humanoid.RigType == Enum.HumanoidRigType.R6 then
					InvokeClient("PlayAnimation", Animations.Throw)
				elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
					InvokeClient("PlayAnimation", Animations.R15Throw)
				end
			end
		end)
		local SpawnPos = (Handle.CFrame * CFrame.new(0, -0.75, -6)).p
		local TargetPos = MouseData.Position
		if Loaded then
			SwitchEvenOddParity = 1
			for i, v in pairs(Kunais) do
				local Angle = (math.ceil((i - 1) / 2) * math.pi / 12 * SwitchEvenOddParity)
				SwitchEvenOddParity = -SwitchEvenOddParity
				v.Angle = Angle
				Throw(v, SpawnPos, TargetPos)
			end
			Kunais = {}
		end
		Throwing = false
		wait(ReloadTime)
		Handle.Transparency = 0
		Loaded = false
	end
	Tool.Enabled = true
end

function FlyProjectile(Part, Hit)
	if Part.Name == "Effect" then
		return
	end
	local AlreadyHit = false
	local function PartHit(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or Part.Name == "Effect" then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)
		return character
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.Velocity.Unit, Length = 2}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = 2}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = Functions.CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {((Player and Player.Character) or nil), Part}, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
		end
		return ((ClosestRay.Hit and ClosestRay) or nil)
	end
	local ClosestRay = CheckForContact(Hit)
	if ClosestRay then
		for i, v in pairs(Part:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end
		Part.Velocity = Vector3.new(0, 0, 0)
		Part.RotVelocity = Vector3.new(0, 0, 0)
		Part.Size = Vector3.new(0.2, 0.2, 0.2)
		Part.CanCollide = false
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		local StickCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
		StickCFrame = (StickCFrame * CFrame.new(0, -((Part.Size.Y / 1.5) - ((SuccessfullyHit and 0.125) or 0)), 0))
		StickCFrame = (CFrame.new(StickCFrame.p, Handle.Position) * CFrame.Angles(Part.CFrame:toEulerAnglesXYZ()))
		local Weld = Create("Motor6D"){
			Part0 = Part,
			Part1 = ClosestRay.Hit,
			C0 = StickCFrame:inverse(),
			C1 = ClosestRay.Hit.CFrame:inverse(),
			Parent = Part,
		}
		local Hit = ClosestRay.Hit
		local SoundPart = BasePart:Clone()
		SoundPart.Name = "Effect"
		SoundPart.Transparency = 1
		SoundPart.Anchored = true
		SoundPart.CanCollide = false
		local Sound = Sounds.Clash:Clone()
		Sound.Pitch = (math.random(1000, 1500) * 0.001)
		Sound.Parent = SoundPart
		Debris:AddItem(SoundPart, 1.5)
		SoundPart.CFrame = Part.CFrame
		SoundPart.Parent = game:GetService("Workspace")
		Sound:Play()
		Part.Name = "Effect"
	end
	if not ManagingProjectiles then
		ManagingProjectiles = true
		Spawn(function()
			while #Projectiles > 0 and ManagingProjectiles and CheckIfAlive() do
				for i, v in pairs(Projectiles) do
					if v and v.Parent and v.Name ~= "Effect" then
						FlyProjectile(v)
					end
				end
				wait()
			end
		end)
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Kunais) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Kunais = {}
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