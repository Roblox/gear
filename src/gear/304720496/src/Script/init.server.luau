--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

DeathWarning = script:WaitForChild("DeathWarning")
PermenantPoisonScript = script:WaitForChild("PermenantPoisonScript")
Particles = script:WaitForChild("Particles")
ArrowTrail = Particles:WaitForChild("ArrowTrail")
PoisonShot = Particles:WaitForChild("PoisonShot")
PoisonScript = script:WaitForChild("PoisonScript")

ZombieScript = script:WaitForChild("ZombieScript")
ZombieModule = require(ZombieScript)

Grips = {
	Unequipped = CFrame.new(0.05, -0.55, 0.75, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.05, -0.55, 0.75, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Animations = {}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

Range = 350
FireRate = 1.2
WindVec = Vector3.new(2, -1, 1).Unit
BarrelOffset = CFrame.new(0, 0, -1.375)

Gravity = 196.20
Rate = (1 / 60)

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 2,
}

Tool.Enabled = true
Tool.Grip = Grips.Unequipped

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

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 1.25)
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "304177674"),
	TextureId = (BaseUrl .. "304177749"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseArrow,
}
ArrowSound = Sounds.Hit:Clone()
ArrowSound.Parent = BaseArrow

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

function DealDamage(Object, Hit, Damage)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not head or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health <= 0 then
		ZombieModule.Zombify(Player, character, false)
	elseif humanoid.Health > 0 then
		local PoisonChance = math.random(1, 100)
		if PoisonChance <= 20 then --% chance of poisoning your enemy
			local PoisonScriptCopy = character:FindFirstChild(PoisonScript.Name)
			if PoisonScriptCopy then
				return
			end
			PoisonScriptCopy = PoisonScript:Clone()
			local ZombieScriptCopy = ZombieScript:Clone()
			ZombieScriptCopy.Parent = PoisonScriptCopy
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = 3},
				{Name = "Delay", Class = "NumberValue", Value = 0.75},
				{Name = "Repeat", Class = "IntValue", Value = 6},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = PoisonScriptCopy,
				}
			end
			local Particle = PoisonShot:Clone()
			Particle.Enabled = true
			Particle.Parent = Object
			Delay(0, (function()
				Particle:Emit(250)
			end))
			PoisonScriptCopy.Disabled = false
			PoisonScriptCopy.Parent = character
			local GuiFound = nil
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BillboardGui") and v.Name == DeathWarning.Name then
					GuiFound = v
					break
				end
			end
			if not GuiFound then
				GuiFound = DeathWarning:Clone()
				local GuiManager = GuiFound:FindFirstChild("GuiManager")
				if GuiManager then
					GuiManager.Disabled = false
				end
				GuiFound.Adornee = head
				GuiFound.Parent = character
			end
			local Counter = GuiFound:FindFirstChild("Count")
			if Counter.Value < Counter.MaxValue then
				Counter.Value = (Counter.Value + 1)
			end
			if Counter.Value >= Counter.MaxValue then
				local PermenantPoisonScriptCopy = character:FindFirstChild(PermenantPoisonScript.Name)
				if not PermenantPoisonScriptCopy then
					PermenantPoisonScriptCopy = PermenantPoisonScript:Clone()
					local ZombieScriptCopy = ZombieScript:Clone()
					ZombieScriptCopy.Parent = PermenantPoisonScriptCopy
					local Values = {
						{Name = "Creator", Class = "ObjectValue", Value = Player},
						{Name = "Damage", Class = "NumberValue", Value = 0},
						{Name = "Delay", Class = "NumberValue", Value = 0.25},
					}
					for i, v in pairs(Values) do
						local Value = Create(v.Class){
							Name = v.Name,
							Value = v.Value,
							Parent = PermenantPoisonScriptCopy,
						}
					end
					PermenantPoisonScriptCopy.Disabled = false
					PermenantPoisonScriptCopy.Parent = character
				end
			end
			GuiFound.Enabled = true
		end
	end
end

function DrawBeam(StartPos, EndPos, Color, FadeDelay)
	local Distance = (StartPos - EndPos).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Material = Enum.Material.Plastic
	for i, v in pairs({"Top", "Bottom", "Front", "Back", "Left", "Right"}) do
		Laser[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
	end
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.Head,
		Scale = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Laser,
	}
	local ParticleRate = Round(Clamp(GetPercentage(0, (Range / 2), Distance), 10, 200), 0.5)
	local ParticleDuration = 2
	for i, v in pairs(ArrowTrail:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			local Particle = v:Clone()
			Particle.Rate = ParticleRate
			if Particle.Lifetime.Max > ParticleDuration then
				ParticleDuration = Particle.Lifetime.Max
			end
			Particle.Enabled = false
			Particle.Parent = Laser
			Delay(0, (function()
				Particle:Emit((ParticleRate * 2.5))
			end))
		end
	end
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

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Fire(StartPos, TargetPos)
	local FakeStartPos = StartPos
	local Vec = (TargetPos - StartPos).unit
	local Drop = false
	local RayHit, RayPos, RayNormal = CastRay(StartPos, Vec, Range, {Character}, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	local Arrow = BaseArrow:Clone()
	Sounds.Fire:Play()
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if humanoid and torso then
			if humanoid.Health > 0 then
				DealDamage(Arrow, RayHit, 15)
			else
				Drop = true
			end
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0 + (math.random(0, 1) * 0.45)))
		Arrow.CFrame = NewCF
		if not Drop then
			local StickWeld = RbxUtility.Create("Weld"){
				Part0 = RayHit,
				Part1 = Arrow,
				C0 = (RayHit.CFrame:inverse() * NewCF),
				C1 = (NewCF:inverse() * NewCF),
				Parent = Arrow,
			}
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
	local HitSound = Arrow:FindFirstChild("Hit")
	if HitSound then
		HitSound:Play()
	end
	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.5)
	end)
end

function CreateDisplayArrow()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	DisplayArrow = BaseArrow:Clone()
	DisplayArrow.Name = "DisplayArrow"
	DisplayArrow.Transparency = ((Tool.Enabled and 0) or 1)
	DisplayArrow.CanCollide = false
	local Weld = Create("Weld"){
		Part0 = Handle,
		Part1 = DisplayArrow,
		C0 = CFrame.new(0, 0.225, -0.9),
		C1 = CFrame.new(0, 0, 0),
		Parent = DisplayArrow
	}
	DisplayArrow.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or MouseDown then
		return
	end
	MouseDown = true
	--while MouseDown and ToolEquipped and CheckIfAlive() do
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition and Tool.Enabled then
			Tool.Enabled = false
			local TargetPosition = MousePosition.Position
			local Offset = (0.5 * 1000)
			TargetPosition = (TargetPosition + Vector3.new((math.random(-Offset, Offset) * 0.001), (math.random(-Offset, Offset) * 0.001), (math.random(-Offset, Offset) * 0.001)))
			Fire((Handle.CFrame * BarrelOffset).p, TargetPosition)
			if DisplayArrow and DisplayArrow.Parent then
				DisplayArrow.Transparency = 1
			end
			wait(FireRate)
			if DisplayArrow and DisplayArrow.Parent then
				DisplayArrow.Transparency = 0
			end
			Tool.Enabled = true
		end
	--end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	MouseDown = false
	ToolEquipped = true
	Tool.Grip = Grips.Equipped
	Spawn(function()
		CreateDisplayArrow()
	end)
end

function Unequipped()
	Spawn(function()
		CreateDisplayArrow()
	end)
	Tool.Grip = Grips.Unequipped
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if not Down and MouseDown then
			MouseDown = false
		end
	elseif mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		--[[if Key == "q" and Down and Special.Enabled and not Special.Active then
			local MousePosition = InvokeClient("MousePosition")
			if not MousePosition then
				return
			end
			MousePosition = MousePosition.Position
			Special.Enabled = false
			Special.Active = true
			Special.Active = false
			Delay(Special.ReloadTime, (function()
				Special.Enabled = true
			end))
		end]]
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CreateDisplayArrow()

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke