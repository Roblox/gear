--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Particles = script:WaitForChild("Particles")
LaserEffects = Particles:WaitForChild("Laser")
SpecialEffects = Particles:WaitForChild("Special")
ParticleScript = script:WaitForChild("ParticleScript")

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
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 2)
ArrowMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "287438060"),
	TextureId = (BaseUrl .. "287438264"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseArrow
}

Grips = {
	Active = CFrame.new(0.3, 0, -0.1, 0.707, 0, 0.707, 0, 1, -0, -0.707, 0, 0.707),
	Equipped = CFrame.new(0.25, 0, 0, 1, 0, 0.35, 0, 1, -0, -0.35, 0, 1),
	Unequipped = CFrame.new(0, 0, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.75, Weight = nil, Speed = nil, Duration = nil, Manual = true},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Manual = true},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil, Manual = true},
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Range = 350
FireRate = 0.75

Rate = (1 / 30)

BarrelOffset = Vector3.new(-0.05, 0.5, -1.5)
WindVec = Vector3.new(2, -1, 1).unit

Damage = {
	Min = 15,
	Max = 100,
}

MaxCharge = 3

Gravity = 196.20

ChargeTable = {
	Charge = 0,
	FullyCharged = false,
	CalculatedCharge = nil,
}

Special = {
	Enabled = true,
	Active = false,
	Duration = 3,
	ReloadTime = 15,
}

MouseDown = false
ToolEquipped = false

Handle.Transparency = 0
Tool.Grip = Grips.Unequipped
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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
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

function DrawBeam(StartPos, EndPos, Color, FadeDelay)
	local Distance = (StartPos - EndPos).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.Head,
		Scale = Vector3.new(1, 1, 1),
		Parent = Laser,
	}
	local ParticleRate = Round(Clamp(GetPercentage(0, (Range / 2), Distance), 10, 125), 0.5)
	local ParticleDuration = 0
	for i, v in pairs(LaserEffects:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			local Particle = v:Clone()
			Particle.Rate = ParticleRate
			if Particle.Lifetime.Max > ParticleDuration then
				ParticleDuration = Particle.Lifetime.Max
			end
			Particle.Enabled = true
			Particle.Parent = Laser
		end
	end
	local ParticleScriptCopy = ParticleScript:Clone()
	local Duration = Create("NumberValue"){
		Name = "Duration",
		Value = 0.25,
		Parent = Laser,
	}
	ParticleScriptCopy.Disabled = false
	ParticleScriptCopy.Parent = Laser
	Laser.Size = Vector3.new(0.2, Distance, 0)
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	Debris:AddItem(Laser, ((ParticleDuration > FadeDelay and ParticleDuration) or FadeDelay))
	Laser.Parent = game:GetService("Workspace")
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	--[[wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end]]
end

function CreateArrow()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	DisplayArrow = BaseArrow:Clone()
	DisplayArrow.Name = "DisplayArrow"
	ArrowWeld = Create("Motor6D"){
		Name = "ArrowWeld",
		Part0 = LeftArm,
		Part1 = DisplayArrow,
		Parent = DisplayArrow,
	}
	DisplayArrow.Parent = Tool
	Spawn(function()
		InvokeClient("SetLocalTransparencyModifier", {Object = DisplayArrow, Transparency = 0, AutoUpdate = true})
	end)
	FocusArrow = RunService.Stepped:connect(function()
		if CheckIfAlive() and ToolEquipped and CheckIfArrowReady() then
			local ArrowCFrame = CFrame.new((LeftArm.CFrame * CFrame.new(0, -1, 0)).p, (Handle.CFrame * CFrame.new(0, 0, -2.25)).p) * CFrame.new(0, 0, -1.2)
			ArrowWeld.C0 = LeftArm.CFrame:toObjectSpace(ArrowCFrame)
			ArrowWeld.C1 = CFrame.new() * CFrame.Angles(math.pi, math.pi, (math.pi / 1))
			if (tick() - ChargeTable.Charge) >= MaxCharge and not ChargeTable.FullyCharged then
				ChargeTable.FullyCharged = true
				local Fire = Create("Fire"){
					Color = Color3.new((170 / 255), (255 / 255), (127 / 255)),
					SecondaryColor = Color3.new((120 / 255), (50 / 255), (0 / 255)),
					Heat = 5,
					Size = 3.5,
					Enabled = true,
					Parent = DisplayArrow,
				}
			end
		elseif FocusArrow then
			FocusArrow:disconnect()
		end
	end)
end

function Fire(StartPos, TargetPos, Damage)
	local FakeStartPos = (CFrame.new(StartPos) * CFrame.new(BarrelOffset)).p
	local Vec = (TargetPos - StartPos).unit
	local Drop = false
	local RayHit, RayPos = CastRay(StartPos, Vec, Range, {Character}, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	local Arrow = BaseArrow:Clone()
	Arrow.Name = "Effect"
	Arrow.CanCollide = false
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
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
		if humanoid then
			if humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			else
				--Drop = true
			end
		end
		local HitSound = Arrow:FindFirstChild("Hit")
		if HitSound then
			HitSound.Pitch = (math.random(80, 120) / 100)
			HitSound:Play()
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0 + (math.random(0, 1) * 0.4)))
		Arrow.CFrame = NewCF
		if not Drop then
			local StickWeld = Create("Weld"){
				Part0 = RayHit,
				Part1 = Arrow,
				C0 = (RayHit.CFrame:inverse() * NewCF),
				C1 = (NewCF:inverse() * NewCF),
				Parent = Arrow,
			}
			if ChargeTable.FullyCharged then
				local CharacterStruck = character
				local Charge = {
					Min = 7,
					Max = 25,
				}
				local ChargeDamage = Round((GetPercentage(0, MaxCharge, ChargeTable.CalculatedCharge)), 0.5)
				ChargeDamage = Clamp(((ChargeDamage < Charge.Min and Charge.Min) or ChargeDamage), Charge.Min, Charge.Max)				
			end
		else
			Arrow.Velocity = Vector3.new(0, 0, 0)
			Arrow.RotVelocity = Vector3.new(0, 0, 0)
		end
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * 300)
	end
	
	Debris:AddItem(Arrow, (10 + (math.random() * 10)))
	Arrow.Parent = game:GetService("Workspace")

	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.5)
	end)
	
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
end

function CreateDisplayArrow(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local DisplayArrow = BaseArrow:Clone()
	DisplayArrow.Name = "DisplayArrow"
	ArrowWeld = Create("Weld"){
		Name = "ArrowWeld",
		Part0 = Handle,
		Part1 = DisplayArrow,
		Parent = DisplayArrow,
	}
	DisplayArrow.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent and RightArm and RightArm.Parent and LeftArm and LeftArm.Parent) and true) or false)
end

function CheckIfArrowReady()
	return (((DisplayArrow and DisplayArrow.Parent and ArrowWeld and ArrowWeld.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	RightArm = Character:FindFirstChild("Right Arm")
	LeftArm = Character:FindFirstChild("Left Arm")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Idle)
		end)
		Tool.Grip = Grips.Equipped
		CreateDisplayArrow(false)
	end)
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		Spawn(function()
			for i, v in pairs(Animations) do
				InvokeClient("StopAnimation", v)
			end
		end)
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v ~= Handle then
				v:Destroy()
			end
		end
		CreateDisplayArrow(true)
		if CheckIfAlive() then
			Humanoid.WalkSpeed = 16
			Humanoid.AutoRotate = true
		end
		Tool.Grip = Grips.Unequipped
	end)
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down and Special.Enabled and not Special.Active then
			Special.Enabled = false
			Special.Active = true
			local CurrentlyEquipped = true
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			Humanoid.WalkSpeed = 0
			Humanoid.AutoRotate = false
			local PartNames = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
			local FireParticles = {}
			for i, v in pairs(Character:GetChildren()) do
				if v:IsA("BasePart") and CheckTableForString(PartNames, v.Name) then
					for ii, vv in pairs(SpecialEffects:GetChildren()) do
						if vv:IsA("ParticleEmitter") then
							local Particle = vv:Clone()
							Particle.Enabled = true
							local ParticleScriptCopy = ParticleScript:Clone()
							local Duration = Create("NumberValue"){
								Name = "Duration",
								Value = 2,
								Parent = Particle,
							}
							ParticleScriptCopy.Disabled = false
							ParticleScriptCopy.Parent = Particle
							table.insert(FireParticles, Particle)
							Debris:AddItem(Particle, 8)
							Particle.Parent = v
						end
					end
				end
			end
			Humanoid.Health = 100
			wait(Special.Duration)
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			if CurrentlyEquipped and CheckIfAlive() then
				Humanoid.WalkSpeed = 16
				Humanoid.AutoRotate = true
			end
			Special.Active = false
			Delay(Special.ReloadTime, (function()
				Special.Enabled = true
			end))
		end
	elseif mode == "Button1Click" then
		local Down = value.Down
		if Down and not MouseDown and Tool.Enabled then
			MouseDown = true
			Tool.Grip = Grips.Active
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.Hold)
			end)
			local FocusArrow
			ChargeTable.Charge = tick()
			ChargeTable.FullyCharged = false
			ChargeTable.CalculatedCharge = nil
			CreateArrow()
			while MouseDown do
				wait()
			end
			Tool.Enabled = false
			local TargetPosition = InvokeClient("MousePosition")
			if TargetPosition and ToolEquipped and CheckIfAlive()then
				ChargeTable.CalculatedCharge = Clamp((tick() - ChargeTable.Charge), 0, MaxCharge)
				Sounds.Fire.Pitch = (0.6 + (0.8 * (ChargeTable.CalculatedCharge / MaxCharge)))
				Sounds.Fire:Play()
				local FireDamage = Round((GetPercentage(0, MaxCharge, ChargeTable.CalculatedCharge)), 0.5)
				FireDamage = Clamp(((FireDamage < Damage.Min and Damage.Min) or FireDamage), Damage.Min, Damage.Max)
				local DisplayArrow = Tool:FindFirstChild("DisplayArrow")
				if DisplayArrow then
					local Weld = DisplayArrow:FindFirstChild("ArrowWeld")
					if Weld and Weld.Part0 and Weld.Part1 and Weld.Part1 == DisplayArrow then
						Spawn(function()
							Fire(DisplayArrow.Position, (TargetPosition.Position + Vector3.new(0, (DisplayArrow.Position.Y - Handle.Position.Y), 0)), FireDamage)
						end)
					end
					DisplayArrow:Destroy()
				end
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Hold)
					InvokeClient("PlayAnimation", Animations.Fire)
				end)
			end
			wait(FireRate)
			Tool.Enabled = true
		elseif not Down and MouseDown then
			Tool.Grip = Grips.Equipped
			MouseDown = false
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

CreateDisplayArrow(true)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ServerControl.OnServerInvoke = OnServerInvoke