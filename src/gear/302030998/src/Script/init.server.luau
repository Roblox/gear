--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

BaseUrl = "http://www.roblox.com/asset/?id="

DeathEffect = script:WaitForChild("DeathEffect")

Grips = {
	Unequipped = CFrame.new(0.05, -0.25, 1.6, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.125, -0.3, 1.5, 0.65, -0.25, 0.7, 0, 1, 0.35, -0.75, -0.25, 0.6),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
	Lunge = Handle:WaitForChild("Lunge"),
}

Range = 350
FireRate = 0.5
WindVec = Vector3.new(2, -1, 1).Unit
BarrelOffset = CFrame.new(2.25, 0.75, -1.25)

Gravity = workspace.Gravity
Rate = (1 / 60)

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 2,
}

Tool.Enabled = true
Tool.Grip = Grips.Unequipped

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
	MeshId = (BaseUrl .. "301934724"),
	TextureId = (BaseUrl .. "301934787"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseArrow,
}
ArrowSound = Sounds.Hit:Clone()
ArrowSound.Parent = BaseArrow

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

function DealDamage(Hit, Damage)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health <= 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				--v:Destroy()
			elseif v:IsA("Accessory") then
				local handle = v:FindFirstChild("Handle")
				if handle then
					local Part = handle:Clone()
					Part.Name = "Effect"
					Part.Velocity = Vector3.new(0, 0, 0)
					Part.RotVelocity = Vector3.new(0, 0, 0)
					Part.CanCollide = true
					Debris:AddItem(Part, 5)
					Part.Parent = game:GetService("Workspace")
				end
				--v:Destroy()
			elseif v:IsA("Tool") then
				v:Destroy()
			end
		end
		local Direction = CFrame.new(Torso.Position, Hit.Position).lookVector
		Direction = Vector3.new(Direction.X, 1, Direction.Z)
		local DeathEffectScript = DeathEffect:Clone()
		DeathEffectScript.WindDirection.Value = Direction
		DeathEffectScript.Force.Value = Vector3.new(8, 5, 10)
		DeathEffectScript.Disabled = false
		DeathEffectScript.Parent = character
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
	end
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
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Head
	Mesh.Scale = Vector3.new(1, (Distance * 5), 1)
	Mesh.Parent = Laser
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = (Laser.CFrame + WindVec * Rate)
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end
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

function Lunge(MousePosition)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	Sounds.Lunge:Play()
	local Blade = BasePart:Clone()
	Blade.Name = "Blade"
	Blade.Transparency = 1
	Blade.Size = Vector3.new(0.2, 0.5, 1.25)
	Blade.CanCollide = false
	local BladeWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = Blade,
		C0 = CFrame.new(0, 0.1, -1.375),
		C1 = CFrame.new(0, 0, 0),
		Parent = Blade
	}
	Debris:AddItem(Blade, 0.5)
	Blade.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		if not BladeWeld or not BladeWeld.Parent or BladeWeld.Part0 ~= Handle or BladeWeld.Part1 ~= Blade then
			return
		end
		DealDamage(Hit, 30)
	end)
	Blade.Parent = Tool
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, 0, Mass),
		velocity = (Direction.lookVector * 75),
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = Direction,
	}
	for i, v in pairs({BodyVelocity, BodyGyro}) do
		Debris:AddItem(v, 0.375)
		v.Parent = Torso
	end
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
		if character:IsA("Accessory") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if humanoid and torso then
			if humanoid.Health > 0 then
				DealDamage(RayHit, 18)
			else
				Drop = true
			end
		end
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0 + (math.random(0, 1) * 0.4)))
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
		C0 = CFrame.new(0, 0.45, -0.125),
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
		if MousePosition then
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
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
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
		local Animation = Animations.Equip
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Equip
		end 
		InvokeClient("PlayAnimation", Animation)
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
		if Key == "q" and Down and Special.Enabled and not Special.Active then
			local MousePosition = InvokeClient("MousePosition")
			if not MousePosition then
				return
			end
			MousePosition = MousePosition.Position
			Special.Enabled = false
			Special.Active = true
			Lunge(MousePosition)
			Special.Active = false
			Delay(Special.ReloadTime, (function()
				Special.Enabled = true
			end))
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

CreateDisplayArrow()

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke