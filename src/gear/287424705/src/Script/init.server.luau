--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

DamageScript = script:WaitForChild("DamageScript")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Unequipped = CFrame.new(0.125, -0.375, 0.75, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0.125, -0.375, 0.75, 0.615603566, -0.275032997, 0.738504648, 0.0724327639, 0.952902436, 0.294500232, -0.784720182, -0.127803445, 0.60653162),
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

Damage = 8
Range = 350
FireRate = 0.25
WindVec = Vector3.new(2, -1, 1).Unit

Gravity = 196.20
Rate = (1 / 60)

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 30,
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

OverseerEye = BasePart:Clone()
OverseerEye.Name = "Projectile"
OverseerEye.Transparency = 0
OverseerEye.Size = Vector3.new(2, 2, 2)
OverseerEye.Anchored = false
OverseerEye.CanCollide = false
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "82326541"),
	TextureId = (BaseUrl .. "82327419"),
	Scale = Vector3.new(3.2, 3.2, 3.2),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = OverseerEye,
}

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 1.25)
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "283707257"),
	TextureId = (BaseUrl .. "283707503"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseArrow,
}
ArrowSound = Sounds.Hit:Clone()
ArrowSound.Parent = BaseArrow

OverseerFire = Create("Fire"){
	Name = "Fire",
	Color = Color3.new((0 / 255), (170 / 255), (0 / 255)),
	SecondaryColor = Color3.new((85 / 255), (170 / 255), (0 / 255)),
	Heat = 0,
	Size = 2,
	Enabled = true,
}

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
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end
end

function Fire(StartPos, TargetPos, SpecialEnabled)
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
		if humanoid then
			if humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
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
		if SpecialEnabled then
			local Radius = 10
			local Fire = OverseerFire:Clone()
			Fire.Parent = Arrow
			local Eye = OverseerEye:Clone()
			Eye.Name = "Effect"
			Eye.Size = Vector3.new(0.2, 0.2, 0.2)
			Eye.Mesh.Scale = (OverseerEye.Mesh.Scale * Radius)
			Eye.Anchored = true
			local EyeCFrame = CFrame.new(RayPos, StartPos)
			EyeCFrame = (EyeCFrame * CFrame.new(0, (Eye.Mesh.Scale.Y / 4), 0))
			Eye.CFrame = EyeCFrame
			Debris:AddItem(Eye, Special.Duration)
			Eye.Parent = game:GetService("Workspace")
			local Eyes = {}
			local BaseEyeCopy = OverseerEye:Clone()
			BaseEyeCopy.Name = "Projectile"
			BaseEyeCopy.Size = (OverseerEye.Size * 1)
			BaseEyeCopy.Mesh.Scale = (OverseerEye.Mesh.Scale * 0.5)
			BaseEyeCopy.CanCollide = false
			BaseEyeCopy.Anchored = true
			local Force = Create("BodyForce"){
				force = Vector3.new(0, (BaseEyeCopy:GetMass() * Gravity), 0),
				Parent = BaseEyeCopy,
			}
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue",  Value = 20},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = BaseEyeCopy,
				}
			end
			local DamageScriptCopy = DamageScript:Clone()
			DamageScriptCopy.Disabled = false
			DamageScriptCopy.Parent = BaseEyeCopy
			for i = 1, math.random(150, 200) do
				local EyeCopy = BaseEyeCopy:Clone()
				EyeCopy.CFrame = (Eye.CFrame * CFrame.Angles((math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001)))
				EyeCopy.CFrame = (EyeCopy.CFrame + EyeCopy.CFrame.lookVector * (math.random(0, ((Radius - 2) * 100)) * 0.01))
				EyeCopy.Velocity = (EyeCopy.CFrame.lookVector * math.random(50, 75))
				table.insert(Eyes, EyeCopy)
				Debris:AddItem(EyeCopy, 2)
				EyeCopy.Parent = game:GetService("Workspace")
			end
			Spawn(function()
				local Rate = 0.035
				local Frames = math.floor(0.5 / Rate)
				Debris:AddItem(Eye, ((Frames * Rate) + 1))
				for Frame = 1, Frames do
					local Percent = (Frame / Frames)
					Eye.Mesh.Scale = ((OverseerEye.Mesh.Scale * Radius) * (1 - Percent))
					Eye.Transparency = (1 - Percent)
					wait(Rate)
				end
				if Eye and Eye.Parent then
					Eye:Destroy()
				end
				for i, v in pairs(Eyes) do
					if v and v:IsA("BasePart") and v.Parent then
						v.Anchored = false
					end
				end
			end)
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
		C0 = CFrame.new(0, 0.45, -0.8),
		C1 = CFrame.new(0, 0, 0),
		Parent = DisplayArrow
	}
	if Special.Active then
		local SpecialFire = OverseerFire:Clone()
		SpecialFire.Parent = DisplayArrow
	end
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
	while MouseDown and ToolEquipped and CheckIfAlive() do
		local MousePosition = InvokeClient("MousePosition")
		if MousePosition then
			Tool.Enabled = false
			local SpecialEnabled = false
			if Special.Active then
				Special.Active = false
				SpecialEnabled = true
				CreateDisplayArrow()
				Delay(Special.ReloadTime, (function()
					Special.Enabled = true
				end))
			end
			local TargetPosition = MousePosition.Position
			local Offset = (0.5 * 1000)
			TargetPosition = (TargetPosition + Vector3.new((math.random(-Offset, Offset) * 0.001), (math.random(-Offset, Offset) * 0.001), (math.random(-Offset, Offset) * 0.001)))
			Fire((Handle.CFrame * CFrame.new(2.25, 0.75, -1.25)).p, TargetPosition, SpecialEnabled)
			if DisplayArrow and DisplayArrow.Parent then
				DisplayArrow.Transparency = 1
			end
			wait(FireRate)
			if DisplayArrow and DisplayArrow.Parent then
				DisplayArrow.Transparency = 0
			end
			Tool.Enabled = true
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	MouseDown = false
	ToolEquipped = true
	Tool.Grip = Grips.Equipped
	Spawn(function()
		CreateDisplayArrow()
		InvokeClient("PlayAnimation", Animations.Equip)
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
			Special.Enabled = false
			Special.Active = true
			CreateDisplayArrow()
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