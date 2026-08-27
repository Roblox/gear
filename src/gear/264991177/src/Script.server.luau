--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Particles = Handle:WaitForChild("Particles")

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

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 5, Max = 8},
	Hit = {Min = 18, Max = 25},
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseFlag = BasePart:Clone()
BaseFlag.Name = "Flag"
BaseFlag.Size = Vector3.new(0.2, 3.75, 2)
BaseFlag.Anchored = true
BaseFlag.CanCollide = false
FlagMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "85005906"),
	TextureId = (BaseUrl .. "85021844"),
	Scale = Vector3.new(1.4, 1.8, 1.4),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseFlag,
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Explosion = Handle:WaitForChild("Explosion"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	BeginCharge = {Animation = Tool:WaitForChild("BeginCharge"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1},
	ReleaseCharge = {Animation = Tool:WaitForChild("ReleaseCharge"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1},
}

MouseDown = Create("BoolValue"){
	Value = false,
}
Special = {
	Charging = false,
	Active = false,
	Reloading = false,
	Duration = 25,
	ReloadTime = 60,
}
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Particles.Enabled = false
Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local Speed = (AttackAnimation.Speed * ((Special.Active and 1.25) or 1))
		local Duration = (AttackAnimation.Duration / Speed)
		local AnimationState = InvokeClient("PlayAnimation", {Animation = AttackAnimation.Animation, FadeTime = AttackAnimation.FadeTime, Weight = AttackAnimation.Weight, Speed = Speed})
		wait(Duration)
		CurrentAnimation = nil
	end
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Radius)
	local NegativeRegion = (Torso.Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Torso.Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = GetParts(Region, 500, IgnoreList)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end 

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local EagleAttacking = character:FindFirstChild("EagleAttacking")
	if EagleAttacking then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	DamageValue = (DamageValue * ((Special.Active and 1.5) or 1))

	local HealthAfter = (humanoid.Health - DamageValue)
	humanoid:TakeDamage(DamageValue)
	if humanoid.Health == 0 or HealthAfter <= 0 then
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or Special.Charging then
		return
	end
	Tool.Enabled = false
	Particles.Enabled = true
	Delay(0.25, (function()
		if not Special.Active then
			Particles.Enabled = false
		end
	end))
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	MouseDown.Value = true
	local CurrentlyEquipped = true
	local CurrentlyDown = true
	for i, v in pairs({ToolUnequipped, MouseLetGo}) do
		if v then
			v:disconnect()
		end
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	MouseLetGo = MouseDown.Changed:connect(function()
		if not MouseDown.Value then
			CurrentlyDown = false
		end
	end)
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
	Attack(AttackAnims)
	if MouseDown.Value and not Special.Charging and not Special.Active and not Special.Reloading then
		Special.Charging = true
		Humanoid.WalkSpeed = 8
		local ChargeAnimation = Animations.BeginCharge
		local ChargeSpeed = 0.25
		Spawn(function()
			InvokeClient("PlayAnimation", {Animation = ChargeAnimation.Animation, FadeTime = ChargeAnimation.FadeTime, Weight = ChargeAnimation.Weight, Speed = ChargeSpeed})
		end)
		local ChargeDuration = (ChargeAnimation.Duration / ChargeSpeed)
		local StartTick = tick()
		while CurrentlyEquipped and CurrentlyDown and ToolEquipped and CheckIfAlive() and (tick() - StartTick) < ChargeDuration do
			wait(Rate)
		end
		local FullyCharged = ((tick() - StartTick) >= ChargeDuration)
		if MouseLetGo then
			MouseLetGo:disconnect()
		end
		MouseDown.Value = false
		if CurrentlyEquipped and ToolEquipped and CheckIfAlive() and FullyCharged then
			Spawn(function()
				InvokeClient("StopAnimation", ChargeAnimation)
			end)
			local ReleaseAnimation = Animations.ReleaseCharge
			local ReleaseSpeed = 2
			local ReleaseDuration = (ReleaseAnimation.Duration / ReleaseSpeed)
			Spawn(function()
				InvokeClient("PlayAnimation", {Animation = ReleaseAnimation.Animation, FadeTime = ReleaseAnimation.FadeTime, Weight = ReleaseAnimation.Weight, Speed = ReleaseSpeed})
			end)
			wait(ReleaseDuration)
			Spawn(function()
				if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
					Special.Active = true
					Special.Reloading = true
					Humanoid.WalkSpeed = 30
					Particles.Enabled = true
					local ExplosionPart = BasePart:Clone()
					ExplosionPart.Name = "Effect"
					ExplosionPart.Transparency = 1
					ExplosionPart.Size = Vector3.new(1, 1, 1)
					ExplosionPart.CanCollide = false
					ExplosionPart.Anchored = true
					local ExplosionSound = Sounds.Explosion:Clone()
					ExplosionSound.Parent = ExplosionPart
					local Explosion = Create("Explosion"){
						Name = "Explosion",
						ExplosionType = Enum.ExplosionType.NoCraters,
						BlastPressure = 0,
						BlastRadius = 100,
						Position = Torso.Position,
						Parent = ExplosionPart,
					}
					Debris:AddItem(ExplosionPart, 1.5)
					ExplosionPart.Parent = game:GetService("Workspace")
					ExplosionSound:Play()
					local ScaleFactor = 50
					local Flag = BaseFlag:Clone()
					Flag.Size = (Flag.Size * ScaleFactor)
					Flag.Mesh.Scale = (Flag.Mesh.Scale * ScaleFactor)
					local Offset = (Torso.CFrame + Vector3.new(0, ((Torso.Size.Y / 2) + (Flag.Size.Y * 0.7) + 5), 0))
					local TorsoPos = (Torso.CFrame + Torso.CFrame.lookVector * 10)
					Flag.CFrame = (CFrame.new(Offset.p, Vector3.new(TorsoPos.p.X, Offset.p.Y, TorsoPos.p.Z)) * CFrame.Angles(-(math.pi / 2), 0, -(math.pi / 2)))
					Debris:AddItem(Flag, 10)
					Flag.Parent = game:GetService("Workspace")
					local PushForce = 75
					local Humanoids = GetPlayersNearby(35)
					for i, v in pairs(Humanoids) do
						local humanoid = v
						local character = humanoid.Parent
						if character then
							local torso = character:FindFirstChild("Torso")
							if torso then
								humanoid.Sit = true
								torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * PushForce)
								humanoid:TakeDamage(65)
							end
						end
					end
					wait(Special.Duration)
					if CheckIfAlive() then
						Humanoid.WalkSpeed = 16
					end
					Particles.Enabled = false
					Special.Active = false
					wait(Special.ReloadTime)
					Special.Reloading = false
				end
			end)
		else
			Spawn(function()
				InvokeClient("StopAnimation", {Animation = ChargeAnimation.Animation, FadeTime = nil})
			end)
		end
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if CheckIfAlive() then
			Humanoid.WalkSpeed = 16
		end
		Special.Charging = false
	end
	for i, v in pairs(Animations) do
		Spawn(function()
			InvokeClient("StopAnimation", v)
		end)
	end
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Particles.Enabled = false
	MouseDown.Value = false
	Special.Charging = false
	Special.Active = false
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	Particles.Enabled = false
	MouseDown.Value = false
	Special.Charging = false
	Special.Active = false
	ToolEquipped = false
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not Mode or not Value or not CheckIfAlive() then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		MouseDown.Value = Down
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)