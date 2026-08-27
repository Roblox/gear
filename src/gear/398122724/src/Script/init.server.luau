--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

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
BaseArrow.Size = Vector3.new(0.2, 0.2, 2.5)
ArrowMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "395019701"),
	TextureId = (BaseUrl .. "395021644"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Parent = BaseArrow
}

Grips = {
	Unequipped = CFrame.new(0.2, 0, -0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.2, 0, -0.5, 0.930484056, -0, 0.366332352, 0, 1, 0, -0.366332322, 0, 0.930484176),
	Active = CFrame.new(0.2, 0, -0.5, 0.65, -0, 0.775, 0, 1, 0, -0.775, 0, 0.65),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 1.5, Weight = nil, Speed = 0.25, Duration = nil},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = 0, Weight = nil, Speed = 0, Duration = nil},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = 1.5, Weight = nil, Speed = 0.25, Duration = nil},
	R15Idle = {Animation = Tool:WaitForChild("R15Idle"), FadeTime = 0, Weight = nil, Speed = 0, Duration = nil},
	R15Fire = {Animation = Tool:WaitForChild("R15Fire"), FadeTime = 0, Weight = nil, Speed = nil, Duration = nil}	
}

Logo = script:WaitForChild("Logo")

ParticleScript = script:WaitForChild("ParticleScript")
ProjectileSparks = script:WaitForChild("ProjectileSparks")

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Range = 350
FireRate = 0.375

Rate = (1 / 30)

BarrelOffset = Vector3.new(-0.05, 0.5, -1.5)
WindVec = Vector3.new(2, -1, 1).unit

Damage = {
	Min = 8,
	Max = 35,
}

MaxCharge = 2.5

Gravity = workspace.Gravity

ChargeTable = {
	Charge = 0,
	FullyCharged = false,
	CalculatedCharge = nil,
}

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 0,
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
	Laser.Size = Vector3.new(0.2, Distance, 0)
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	Debris:AddItem(Laser, FadeDelay)
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
	ArrowWeld = Create("Weld"){
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
			local ArrowCFrame = (CFrame.new((LeftArm.CFrame * CFrame.new(-0.1125, -1, 0)).p, (Handle.CFrame * CFrame.new(0, 0.25, -2.25)).p) * CFrame.new(0, 0, -1.2) * CFrame.Angles(0, 0, 0))
			ArrowWeld.C0 = LeftArm.CFrame:toObjectSpace(ArrowCFrame)
			ArrowWeld.C1 = CFrame.new() * CFrame.Angles(math.pi, math.pi, (math.pi / 1))
			if (tick() - ChargeTable.Charge) >= MaxCharge and not ChargeTable.FullyCharged then
				ChargeTable.FullyCharged = true
				local Arrows = {}
				for i, v in pairs(Arrows) do
					local Arrow = DisplayArrow:Clone()
					local Weld = Arrow.ArrowWeld
					Weld.Part0 = DisplayArrow
					Weld.Part1 = Arrow
					Weld.C0 = v
					Arrow.Parent = Tool
				end
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
	local Particles = ProjectileSparks:Clone()
	Particles.Enabled = true
	local ParticleScriptCopy = ParticleScript:Clone()
	Create("NumberValue"){
		Name = "Duration",
		Value = 0.5,
		Parent = ParticleScriptCopy,
	}
	ParticleScriptCopy.Disabled = false
	ParticleScriptCopy.Parent = Particles
	Particles.Parent = Arrow
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Accessory") or character:IsA("Tool") then
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
				local TotalDamage = Damage
				if RayHit.Name == "Head" then
					TotalDamage = (TotalDamage * 1.25)
				end
				humanoid:TakeDamage(TotalDamage)
				if humanoid.Health <= 0 then
				end
			else
				--Drop = true
			end
		end
		local HitSound = Arrow:FindFirstChild("Hit")
		if HitSound then
			HitSound.Pitch = (math.random(80, 120) / 100)
			HitSound:Play()
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0.9 + (math.random(0, 1) * 0.4)))
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
				if RayHit then
				end
			end
			if not Special.Enabled and Special.Active then
				Special.Active = false
				Delay(Special.ReloadTime, (function()
					Special.Enabled = true
				end))
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
		C0 = CFrame.new(-0.1125, 0, 0),
		C1 = CFrame.new(0, 0, 0),
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Spawn(function()
		if LogoCopy and LogoCopy.Parent then
			LogoCopy:Destroy()
		end
		LogoCopy = Logo:Clone()
		LogoCopy.Adornee = Head
		LogoCopy.Enabled = true
		Debris:AddItem(LogoCopy, 5)
		LogoCopy.Parent = Head
		CreateDisplayArrow(false)
		local Animation = Animations.Idle
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Idle
		end 
		InvokeClient("PlayAnimation", Animation)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	Tool.Grip = Grips.Unequipped
	Spawn(function()
		if not Tool.Parent:IsA("Backpack") then
			CreateDisplayArrow(true)
		end
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
		end
	elseif mode == "Button1Click" then
		local Down = value.Down
		if Down and not MouseDown and Tool.Enabled then
			MouseDown = true
			Tool.Grip = Grips.Active
			local CurrentlyEquipped = true
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			local Animation = Animations.Hold
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Animation = Animations.R15Hold
			end 
			Spawn(function()
				InvokeClient("PlayAnimation", Animation)
			end)
			local FocusArrow
			ChargeTable.Charge = tick()
			ChargeTable.FullyCharged = false
			ChargeTable.CalculatedCharge = nil
			CreateArrow()
			while MouseDown and CurrentlyEquipped and ToolEquipped and CheckIfAlive() do
				wait()
			end
			local TargetPosition = InvokeClient("MouseData")
			if Tool.Enabled and TargetPosition and CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
				Tool.Enabled = false
				ChargeTable.CalculatedCharge = Clamp((tick() - ChargeTable.Charge), 0, MaxCharge)
				Sounds.Fire.Pitch = (0.6 + (0.8 * (ChargeTable.CalculatedCharge / MaxCharge)))
				Sounds.Fire:Play()
				local FireDamage = Round((GetPercentage(0, MaxCharge, ChargeTable.CalculatedCharge)), 0.5)
				FireDamage = Clamp(((FireDamage < Damage.Min and Damage.Min) or FireDamage), Damage.Min, Damage.Max)
				local Arrows = {}
				for i, v in pairs(Tool:GetChildren()) do
					if v:IsA("BasePart") and v.Name == "DisplayArrow" then
						local Weld = v:FindFirstChild("ArrowWeld")
						if Weld and Weld.Part0 and Weld.Part1 and Weld.Part1 == v then
							table.insert(Arrows, v)
						end
					end
				end
				local TotalDamage = FireDamage
				for i, v in pairs(Arrows) do
					Spawn(function()
						Fire(v.Position, (TargetPosition.Position + Vector3.new(0, (v.Position.Y - Handle.Position.Y), 0)), TotalDamage)
					end)
				end
				for i, v in pairs(Tool:GetChildren()) do
					if v:IsA("BasePart") and v ~= Handle then
						v:Destroy()
					end
				end
				Animation = Animations.Hold
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Hold
				end 
				InvokeClient("StopAnimation", Animation)
				Animation = Animations.Fire
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Fire
				end 
				InvokeClient("PlayAnimation", Animation)
			
			end
			wait(FireRate / 2)
			if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
				Tool.Grip = Grips.Equipped
			end
			wait(FireRate / 2)
			Tool.Enabled = true
		elseif not Down and MouseDown then
			Tool.Grip = Grips.Unequipped
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

Delay(0, (function()
	CreateDisplayArrow(true)
end))

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ServerControl.OnServerInvoke = OnServerInvoke
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)