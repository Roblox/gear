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


BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))
ProjectileScript = script:WaitForChild("ProjectileScript")
EpicFire = script:WaitForChild("EpicFire")

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 8, Max = 8},
	Hit = {Min = 15, Max = 22},
	Dash = {Min = 17, Max = 24},
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

Wings = BasePart:Clone()
Wings.Name = "Wings"
Wings.Size = Vector3.new(0.2, 0.2, 0.2)
Wings.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "223377708"),
	TextureId = (BaseUrl .. "223377828"),
	Scale = Vector3.new(1.25, 1.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = Wings,
}

Fireball = BasePart:Clone()
Fireball.Name = "Fireball"
Fireball.Transparency = 0.5
Fireball.BrickColor = BrickColor.new("New Yeller")
Fireball.Material = Enum.Material.Neon
Fireball.Shape = Enum.PartType.Ball
Fireball.Size = Vector3.new(6, 6, 6)
Fireball.CanCollide = false
Fire = EpicFire:Clone()
Fire.LockedToPart = false
Fire.Enabled = true
Fire.Parent = Fireball

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Spin = Handle:WaitForChild("Spin"),
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.75},
	HoldShield = {Animation = Tool:WaitForChild("HoldShield"), FadeTime = 0.25, Weight = nil, Speed = 1, Duration = nil},
	Dash = {Animation = Tool:WaitForChild("Dash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
}

Specials = {
	LightBeam = {
		Enabled = true,
		Active = false,
		Duration = 8,
		ReloadTime = 90,
	},
}

TouchConns = {}
LastClick = 0
CanBlock = true
Blocking = false
DashEnabled = true
Dashing = false
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

Handle.Transparency = 0
Tool.Enabled = true

function CraftShield(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew or not CheckIfAlive() then
		return
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	Shield = BasePart:Clone()
	Shield.Name = "Shield"
	Shield.Size = Vector3.new(2.5, 3, 0.5)
	Create("SpecialMesh"){
		Name = "Mesh",
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "416669201"),
		TextureId = (BaseUrl .. "416669357"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Shield,
	}
	ShieldWeld = Create("Weld"){
		Name = "Weld",
		Part0 = LeftArm,
		Part1 = Shield,
		C0 = (CFrame.new(-0.5, 0, 0) * CFrame.Angles(-(math.pi / 2), (math.pi / 2), 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = Shield,
	}
	Shield.Parent = Tool
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
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
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	local PossibleDamage = Damage.Touch
	if Dashing then
		PossibleDamage = Damage.Dash
	elseif CurrentAnimation then
		PossibleDamage = Damage.Hit
	end
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	humanoid:TakeDamage(DamageValue)
	if humanoid.Health <= 0 then
	else
	end
end

function GetPlayersNearby(Position, Radius)
	local Humanoids = {}
	local NegativeRegion = (Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Position + Vector3.new(Radius, Radius, Radius))
	local Region = Region3.new(NegativeRegion, PositiveRegion)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	local Parts = Functions.GetParts(Region, 500, IgnoreList)
	for i, v in pairs(Parts) do
		local character = v.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function DashSpin()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
		
	Dashing = true
	
	local MousePos = MouseData.Position
	local Dir = ((MousePos - Torso.Position) * Vector3.new(1, 0, 1)).Unit
	local TorsoCF = Torso.CFrame
	
	local TorsoPosition = Torso.Position
	local Direction = (CFrame.new(Handle.Position, MousePos).lookVector * Vector3.new(1, 0, 1))
	DashGyro = Create("BodyGyro"){
		P = 30000,
		maxTorque = Vector3.new(30000, 30000, 30000),
		cframe = (CFrame.new(TorsoPosition, (MousePos * Vector3.new(1, 0, 1) + Vector3.new(0, TorsoPosition.Y, 0))) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		Parent = Torso,
	}
	DashPosition = Create("BodyPosition"){
		P = 100000,
		maxForce = Vector3.new(100000, 100000, 100000),
		position = (TorsoPosition + Vector3.new(0, 1.5, 0)),
		Parent = Torso,
	}
	DashAngularVelocity = Create("BodyAngularVelocity"){
		P = 100000,
		maxTorque = Vector3.new(100000, 100000, 100000),
	}
	DashVelocity = Create("BodyVelocity"){
		P = 100000,
		maxForce = Vector3.new(100000, 0, 100000),
		velocity = (Direction * 64),
	}
	
	local RemoveTime = 1.75
	local Flames = {}
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency < 1 then
			local Fire = EpicFire:Clone()
			Fire.Enabled = true
			Debris:AddItem(Fire, (RemoveTime + 1.5))
			local TouchConn = v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
					return
				end
				local character = Hit.Parent
				if character == Character then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health <= 0 then
					return
				end
				local player = Players:GetPlayerFromCharacter(character)
				if player and (player == Player or Functions.IsTeamMate(Player, player)) then
					return
				end
				local PossibleDamage = Damage.Dash
				local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
				local HealthAfter = (humanoid.Health - DamageValue)
				humanoid:TakeDamage(DamageValue)
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(DamageValue)
			end)
			table.insert(TouchConns, TouchConn)
			table.insert(Flames, Fire)
			Fire.Parent = v
		end
	end
	Delay(RemoveTime, (function()
		for i, v in pairs(TouchConns) do
			if v then
				v:disconnect()
			end
		end
		TouchConns = {}
		for i, v in pairs(Flames) do
			v.Enabled = false
		end
	end))
	for i, v in pairs({DashGyro, DashPosition, DashAngularVelocity, DashVelocity}) do
		Debris:AddItem(v, RemoveTime)
	end
	
	DashGyro.Parent = Torso
	DashPosition.Parent = Torso
	
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Dash)
	end)
	
	wait(0.5)
	
	Sounds.Spin:Play()
	
	DashGyro.maxTorque = Vector3.new(DashPosition.P, 0, DashPosition.P)
	DashPosition.maxForce = Vector3.new(0, DashPosition.P, 0)
	DashVelocity.Parent = Torso
	DashAngularVelocity.angularvelocity = Torso.CFrame:vectorToWorldSpace(Vector3.new(0, -30, 0))
	DashAngularVelocity.Parent = Torso
	
	wait(1.25)
	
	Dashing = false
	
end

function Activated()
	if not ToolEquipped or Blocking or Dashing or Specials.LightBeam.Active then
		return
	end
	local Now = tick()
	if (Now - LastClick) <= 0.3 and DashEnabled then
		DashEnabled = false
		DashSpin()
		wait(7)
		DashEnabled = true
	end
	LastClick = tick()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.SideSwipe}
	Attack(AttackAnims)
	Tool.Enabled = true
end

function Unblock()
	if not Blocking then
		return
	end
	Spawn(function()
		InvokeClient("StopAnimation", Animations.HoldShield)
	end)
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	Blocking = false
	wait(5)
	CanBlock = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		local IgnoreHealthChange = false
		local CurrentHealth = Humanoid.Health
		if HealthChanged then
			HealthChanged:disconnect()
		end
		HealthChanged = Humanoid.Changed:connect(function(Property)
			local NewHealth = Humanoid.Health
			if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
				if NewHealth < CurrentHealth then
					local DamageDealt = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					if Blocking then
						Humanoid.Health = (Humanoid.Health + (DamageDealt * 0.33))
					end
					IgnoreHealthChange = false
				end
			end
			CurrentHealth = NewHealth
		end)
		CraftShield(true)
	end)
	Blocking = false
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		if HealthChanged then
			HealthChanged:disconnect()
		end
		for i, v in pairs({WingsCopy, FlyPosition}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		for i, v in pairs(TouchConns) do
			if v then
				v:disconnect()
			end
		end
		TouchConns = {}
		CraftShield(false)
		Unblock()
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPressed" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" then
			if Down and not Blocking and CanBlock then
				CanBlock = false
				Blocking = true
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.HoldShield)
				end)
				Humanoid.WalkSpeed = 8
			elseif not Down and Blocking then
				Unblock()
			end
		elseif Key == "e" and Down then
			local Special = Specials.LightBeam
			if not Special.Enabled or Special.Active then
				return
			end
			local RayHit, RayPos, RayNormal, RayMaterial = Functions.CastRay(Torso.Position, Vector3.new(0, -1, 0), 200, {Character}, false)
			if not RayHit then
				return
			end
			Special.Enabled = false
			Special.Active = true
			local CurrentlyEquipped = true
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			WingsCopy = Wings:Clone()
			Create("Weld"){
				Name = "Weld",
				Part0 = Torso,
				Part1 = WingsCopy,
				C0 = (CFrame.new(0, 3.25, 1.75) * CFrame.Angles((math.pi / 16), 0, 0)),
				C1 = CFrame.new(0, 0, 0),
				Parent = WingsCopy,
			}
			local Weight = 0
			local ConnectedParts = Functions.GetAllConnectedParts(Torso)
			for i, v in pairs(ConnectedParts) do
				Weight = (Weight + v:GetMass())
			end
			Weight = (Weight * Gravity * 2)
			FlyPosition = Create("BodyPosition"){
				Name = "BodyPosition",
				maxForce = Vector3.new(Weight, Weight, Weight),
				position = (Torso.Position + Vector3.new(0, 30, 0)),
			}
			Debris:AddItem(FlyPosition, (Special.Duration + 3))
			Debris:AddItem(WingsCopy, (Special.Duration + 4))
			FlyPosition.Parent = Torso
			WingsCopy.Parent = Tool
			wait(2)
			local Start = tick()
			local End = (Start + Special.Duration)
			local Radius = 30
			while tick() < End and CurrentlyEquipped and ToolEquipped and CheckIfAlive() do
				wait((math.random(350, 1000) * 0.001))
				local MouseData = InvokeClient("MouseData")
				if CurrentlyEquipped and ToolEquipped and CheckIfAlive() and MouseData and MouseData.Position then
					for i = 1, math.random(1, 12) do
						local FireballCopy = Fireball:Clone()
						local Size = math.random(5, 9)
						FireballCopy.Size = Vector3.new(Size, Size, Size)
						local ProjectileScriptCopy = ProjectileScript:Clone()
						local Values = {
							{Name = "Creator", Class = "ObjectValue", Value = Player},
							{Name = "Damage", Class = "NumberValue", Value = 60},
						}
						for i, v in pairs(Values) do
							local Value = Create(v.Class){
								Name = v.Name,
								Value = v.Value,
								Parent = FireballCopy,
							}
						end
						ProjectileScriptCopy.Disabled = false
						ProjectileScriptCopy.Parent = FireballCopy
						local RadiusMult = (Radius * 1000)
						local FireballOffset = (Vector3.new(math.random(-RadiusMult, RadiusMult), math.random(10000, 20000), math.random(-RadiusMult, RadiusMult)) * 0.001)
						FireballCopy.CFrame = (Torso.CFrame + FireballOffset)
						local Direction = CFrame.new(FireballCopy.Position, MouseData.Position).lookVector
						local Speed = 75
						local Velocity = (Direction * Speed)
						local Weight = (FireballCopy:GetMass() * Gravity)
						local BodyVeloicty = Create("BodyVelocity"){
							maxForce = Vector3.new(Weight, Weight, Weight),
							velocity = Velocity,
							Parent = FireballCopy,
						}
						FireballCopy.Velocity = Velocity
						Debris:AddItem(FireballCopy, 8)
						FireballCopy.Parent = game:GetService("Workspace")
						wait(0.1)
					end
				end
			end
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			Special.Active = false
			wait(Special.ReloadTime)
			Special.Enabled = true
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CraftShield(false)
end))

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)