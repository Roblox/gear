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

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseParticle = BasePart:Clone()
BaseParticle.Name = "Particle"
BaseParticle.Transparency = 1
BaseParticle.Size = Vector3.new(0.5, 0.5, 0.5)
BaseParticle.CanCollide = false
ParticleFire = Instance.new("Fire")
ParticleFire.Name = "Fire"
ParticleFire.Size = 2
ParticleFire.Heat = 9
ParticleFire.Color = Color3.new((236 / 255), (139 / 255), (70 / 255))
ParticleFire.SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255))
ParticleFire.Parent = BaseParticle

TrailEffectPart = BasePart:Clone()
TrailEffectPart.Name = "TrailEffectPart"
TrailEffectPart.Size = Vector3.new(1, 0.4, 1)
TrailEffectPart.Anchored = true
TrailEffectPart.CanCollide = false
TrailMesh = Instance.new("SpecialMesh", TrailEffectPart)
TrailMesh.MeshType = Enum.MeshType.FileMesh
TrailMesh.TextureId = (BaseUrl .. "120736941")
TrailMesh.MeshId = (BaseUrl .. "1078075")
TrailMesh.Scale = Vector3.new(1.5, 3, 1.5)

PossibleSplashColors = {
	Color3.new((255 / 255), (0 / 255), (0 / 255)),
	Color3.new((255 / 255), (255 / 255), (255 / 255)),
	Color3.new((0 / 255), (0 / 255), (255 / 255))
}

ColorVectors = {
	Vector3.new(0, 0, (255 / 255)),
	Vector3.new((255 / 255), 0, 0),
	Vector3.new((255 / 255), (255 / 255), (255 / 255))
}
CurrentColor = 1

Animations = {
	BeginSmash = {Animation = Tool:WaitForChild("BeginSmash"), FadeTime = nil, Weight = nil, Speed = nil},
	EndSmash = {Animation = Tool:WaitForChild("EndSmash"), FadeTime = nil, Weight = nil, Speed = nil},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = nil},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil},
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil},
	Run = {Animation = Tool:WaitForChild("Run"), FadeTime = nil, Weight = nil, Speed = nil},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil}
}

Sounds = {
	Spin = Handle:WaitForChild("Spin"),
	Swish = Handle:WaitForChild("Swish"),
	HitGround = Handle:WaitForChild("HitGround")
}

Rate = (1 / 60)

LastClick = 0

HammerTrailOn = false
PlayingRunning = false
DoingSwing = false
DoingSmash = false
DoingSpin = false
TrailActive = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ToolEquipped = false

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet", TrailEffectPart.Name, BaseParticle.Name}

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	Debris:AddItem(CreatorTag, 2)
	CreatorTag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Frand(Low, High)
	return (Low + math.random() * (High - Low))
end

function CreateSplashEffect(Pos)
	local SplashParts = {}
	for i = 1, 20 do
		local Particle = BaseParticle:Clone()
		Particle.Fire.Color = PossibleSplashColors[math.random(1, #PossibleSplashColors)]
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.P = 100000
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
		BodyVelocity.velocity = Vector3.new(Frand(-1, 1), Frand(0.5, 1), Frand(-1, 1)).unit * Frand(20, 80)
		BodyVelocity.Parent = Particle
		Particle.Velocity = BodyVelocity.velocity
		table.insert(SplashParts, Particle)
		Debris:AddItem(Particle, 0.5)
		Particle.Parent = game:GetService("Workspace")
		Particle.CFrame = CFrame.new(Pos)
		Delay(Frand(0.1, 0.4), (function()
			if Particle and Particle.Parent then
				Particle:Destroy()
			end
		end))
	end
end

function MakeTrail()
	Spawn(function()
		local LastEffectPos
		TrailActive = true
		Humanoid.AutoRotate = false
		while HammerTrailOn and ToolEquipped and CheckIfAlive() do
			Spawn(function()
				if not ParticleSpawn or not ParticleSpawn.Parent then
					ParticleSpawn = BasePart:Clone()
					ParticleSpawn.Name = "ParticleSpawn"
					ParticleSpawn.Transparency = 1
					ParticleSpawn.CanCollide = false
					local Weld = Instance.new("Weld")
					Weld.Part0 = Handle
					Weld.Part1 = ParticleSpawn
					Weld.C0 = CFrame.new(2.72, 0, 1)
					Weld.Parent = ParticleSpawn
					ParticleSpawn.Parent = Handle
				end
				local TrailPart = TrailEffectPart:Clone()
				local SpawnPos = ParticleSpawn.CFrame
				if LastEffectPos then
					local Distance = (SpawnPos.p - LastEffectPos).magnitude
					TrailPart.Mesh.Scale = Vector3.new(1.5, (Distance / 0.4), 1.5)
					CurrentColor = (CurrentColor + 1)
					if CurrentColor > #ColorVectors then
						CurrentColor = 1
					end
					TrailPart.Mesh.VertexColor = ColorVectors[CurrentColor]
					Spawn(function()
						for i = 0, 1, 0.2 do
							TrailPart.Transparency = i
							wait(Rate)
						end
						TrailPart.Transparency = 1
					end)
					Debris:AddItem(TrailPart, 0.2)
					TrailPart.Parent = game:GetService("Workspace")
					TrailPart.CFrame = CFrame.new(SpawnPos.p, LastEffectPos) * CFrame.Angles(-(math.pi / 2), 0, 0)
				end
				LastEffectPos = SpawnPos.p
			end)
			wait(Rate)
		end
		if ParticleSpawn and ParticleSpawn.Parent then
			ParticleSpawn:Destroy()
		end
		Humanoid.AutoRotate = true
		TrailActive = false
		LastEffectPos = nil
	end)
end

function IsRunning()
	return ((Torso.Velocity - Vector3.new(0, Torso.Velocity.y, 0)).magnitude > 1)
end

Handle.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage((DoingSpin and 10) or (DoingSmash and 30) or (DoingSwing and 100) or 0)
end)

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	wait(1.135)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	PlayingRunning = IsRunning()
	if PlayingRunning then
		InvokeClient("PlayAnimation", {Animation = Animations.Run.Animation, FadeTime = 0})
	else
		InvokeClient("PlayAnimation", {Animation = Animations.Idle.Animation, FadeTime = 0})
	end
	ToolEquipped = true
	Spawn(function()
		while ToolEquipped do
			local Running = IsRunning()
			if not DoingSwing and not DoingSmash then
				if Running and not PlayingRunning then
					InvokeClient("StopAnimation", Animations.Idle)--{Animation = Animations.Idle.Animation, FadeTime = 0.3})
					InvokeClient("PlayAnimation", {Animation = Animations.Run.Animation, FadeTime = 0})
				elseif not Running and PlayingRunning then
					InvokeClient("StopAnimation", Animations.Idle)--{Animation = Animations.Run.Animation, FadeTime = 0.3})
					InvokeClient("PlayAnimation", {Animation = Animations.Idle.Animation, FadeTime = 0})
				end
			end
			PlayingRunning = Running
			wait(Rate)
		end
	end)
end

function Unequipped()
	HammerTrailOn = false
	DoingSwing = false
	DoingSpin = false
	DoingSmash = false
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({SpinForce, SmashForce}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "MouseClick" then
			local Down = value.Down
			if Down then
				if (tick() - LastClick) < 0.3 and not DoingSmash and not DoingSpin and not TrailActive then
					LastClick = 0
					InvokeClient("StopAnimation", Animations.Swing)
					DoingSwing = false
					if IsRunning() then
						InvokeClient("PlayAnimation", Animations.Run)
					else
						InvokeClient("PlayAnimation", Animations.Idle)
					end
					DoingSmash = true
					Humanoid.Jump = true
					InvokeClient("DisableJump", true)
					SmashForce = Instance.new("BodyVelocity")
					SmashForce.Name = "SmashForce"
					SmashForce.maxForce = Vector3.new(0, 1000000, 0)
					SmashForce.velocity = Vector3.new(0, 100, 0)
					SmashForce.Parent = Torso
					game.Debris:AddItem(SmashForce, 0.1)
					InvokeClient("PlayAnimation", Animations.BeginSmash)
					wait(0.1)
					if Torso.Velocity.y > 0 then
						while Torso.Velocity.y > 0 do
							wait(Rate)
						end
						InvokeClient("StopAnimation", {Animation = Animations.BeginSmash.Animation, FadeTime = 0})
						HammerTrailOn = true
						MakeTrail()
						InvokeClient("PlayAnimation", {Animation = Animations.EndSmash.Animation, FadeTime = 0})
						local RayHit, RayPos, RayNormal = nil
						local AttackTime = tick()
						while (tick() - AttackTime) < 3 and DoingSmash and ToolEquipped and CheckIfAlive() and not RayHit do
							RayHit, RayPos, RayNormal = CastRay(Torso.Position, Vector3.new(0, -1, 0), (Character:GetModelSize().Y / 2), {Character}, false)
							wait(Rate)
						end
						if RayHit then
							local Direction = (Handle.CFrame * CFrame.new(2.72, 0.01, 1) * CFrame.Angles(0,(math.pi / 2),(math.pi / 2))).p
							CreateSplashEffect(Direction)
							Sounds.HitGround:Play()
						end
					end
					InvokeClient("StopAnimation", Animations.EndSmash)
					InvokeClient("DisableJump", false)
					HammerTrailOn = false
					DoingSmash = false
				elseif not DoingSpin and not DoingSmash and not DoingSwing and not TrailActive then
					LastClick = tick()
					DoingSwing = true
					InvokeClient("StopAnimation", Animations.Run)
					InvokeClient("StopAnimation", Animations.Idle)
					Sounds.Swish:Play()
					InvokeClient("PlayAnimation", Animations.Swing)
					wait(1.3)
					if DoingSwing then
						if IsRunning() then
							InvokeClient("PlayAnimation", {Animation = Animations.Run.Animation, FadeTime = 0})
						else
							InvokeClient("PlayAnimation", {Animation = Animations.Idle.Animation, FadeTime = 0})
						end
					end
					DoingSwing = false
				end
			end
		elseif mode == "KeyPress" then
			local Down = value.Down
			local Key = value.Key
			local ByteKey = string.byte(Key)
			if Key == "q" then
				if Down then
					if not DoingSmash and not DoingSwing and not TrailActive then
						Sounds.Spin:Play()
						DoingSpin = true
						InvokeClient("PlayAnimation", Animations.Spin)
						for i, v in pairs({SpinForce, SmashForce}) do
							if v and v.Parent then
								v:Destroy()
							end
						end
						SpinForce = Instance.new("BodyAngularVelocity")
						SpinForce.maxTorque = Vector3.new(0, 10000000, 0)
						SpinForce.angularvelocity = Vector3.new(0, 10, 0)
						SpinForce.P = 10000
						SpinForce.Parent = Torso
						HammerTrailOn = true
						MakeTrail()
						while DoingSpin do
							wait(Rate)
						end
						Sounds.Spin:Stop()
						HammerTrailOn = false
						InvokeClient("StopAnimation", Animations.Spin)
						if SpinForce and SpinForce.Parent then
							SpinForce:Destroy()
						end
						DoingSpin = false
						if IsRunning then
							InvokeClient("PlayAnimation", Animations.Run)
						else
							InvokeClient("PlayAnimation", Animations.Idle)
						end
					end
				else
					DoingSpin = false
				end
			end
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

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("BasePart") and v.Name == "ParticleSpawn" then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)