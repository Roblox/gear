--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

MeshData = {
	CrossbowAndArrow = 209275932,
	Crossbow = 209275901,
	Arrow = 209275768,
	Texture = 209276006
}

for i, v in pairs(MeshData) do
	MeshData[i] = (BaseUrl .. tostring(v))
end

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.5, 0.2, 2)
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = MeshData.Arrow
ArrowMesh.TextureId = MeshData.Texture
ArrowMesh.Scale = Vector3.new(1, 1, 1)
ArrowMesh.VertexColor = Vector3.new(1, 1, 1)
ArrowMesh.Parent = BaseArrow

Animations = {
	IdlePose = {Animation = Tool:WaitForChild("IdlePose"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	StealthPose = {Animation = Tool:WaitForChild("StealthPose"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Release = {Animation = Tool:WaitForChild("Release"), FadeTime = nil, Weight = nil, Speed = 2, Duration = nil}
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit"),
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Range = 350
FireRate = 1

Damage = {
	Min = 15,
	Max = 45
}

Multiplier = 1.25

Parts = {}

Rate = (1 / 60)

BarrelOffset = Vector3.new(-0.05, 0.5, -1.5)
WindVec = Vector3.new(2, -1, 1).unit

Gravity = 196.20
ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}

MouseDown = false
ToolEquipped = false

Tool.Enabled = true

function GetVector(cframe, Direction)
	local px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz = cframe:components()
	
	local Position = Vector3.new(px, py, pz)
	local Right = Vector3.new(xx, xy, xz)
	local Top = Vector3.new(yx, yy, yz)
	local Back = Vector3.new(zx, zy, zz)
	
	return (
		(Direction == Enum.NormalId.Top and Top) or
		(Direction == Enum.NormalId.Back and Back) or
		(Direction == Enum.NormalId.Right and Right)
	)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
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

function CastRay(StartPos, Vec, Length, IgnoreList, DelayIfHit)
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), IgnoreList)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), IgnoreList, DelayIfHit)
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

function Fire(StartPos, TargetPos)
	local FakeStartPos = (Handle.CFrame * CFrame.new(BarrelOffset)).p
	local Vec = (TargetPos - StartPos).unit
	local Drop = false
	local RayHit, RayPos, RayNormal = CastRay(StartPos, Vec, Range, {Character}, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	local Arrow = BaseArrow:Clone()
	if RayHit then
		local Distance = (StartPos - RayPos).magnitude
		local DamageValue = Round(Clamp(GetPercentage(0, (Range / 2), Distance), Damage.Min, Damage.Max), 0.5)
		DamageValue = ((RayHit.Name == "Head" and (DamageValue * Multiplier)) or DamageValue)
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
		if humanoid and humanoid.Health > 0 then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
		local HitSound = Sounds.Hit:Clone()
		HitSound.Pitch = (math.random(80, 123) / 100)
		HitSound:Play()
		Arrow.CanCollide = false
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0.9 + (math.random(0, 1) * 0.4)))
		Arrow.CFrame = NewCF
		local StickWeld = Instance.new("Weld")
		StickWeld.Part0 = RayHit
		StickWeld.Part1 = Arrow
		StickWeld.C0 = (RayHit.CFrame:inverse() * NewCF)
		StickWeld.C1 = (NewCF:inverse() * NewCF)
		StickWeld.Parent = Arrow
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * 300)
	end
	
	Debris:AddItem(Arrow, (10 + (math.random() * 10)))
	Arrow.Parent = game:GetService("Workspace")

	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.5)
	end)
	
end

function CheckObjectClass(Object, ClassNames)
	for i, v in pairs(ClassNames) do
		if Object:IsA(v) then
			return true
		end
	end
	return false
end

function GetAllChildren(Parent, Classes)
	Objects = {}
	local function GetChildren(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if CheckObjectClass(v, Classes) then
				table.insert(Objects, v)
			end
			GetChildren(v)
		end
	end
	GetChildren(Parent)
	return Objects
end

function SetUpPoseMonitor()
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyGyro") then
			v:Destroy()
		end
	end
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(0, 0, 0)
	BodyGyro.Parent = Torso
	while BodyGyro and BodyGyro.Parent and ToolEquipped and CheckIfAlive() do
		local Directions = {
			Left = {Direction = (GetVector(Torso.CFrame, Enum.NormalId.Right) * -1), Length = (Torso.Size.X * 1.5)},
			Right = {Direction = (GetVector(Torso.CFrame, Enum.NormalId.Right) * 1), Length = (Torso.Size.X * 1.5)},
			Back = {Direction = (GetVector(Torso.CFrame, Enum.NormalId.Back) * 1), Length = (Torso.Size.Z * 1.5)},
		}
		local RayData = {}
		for i, v in pairs(Directions) do
			local RayHit, RayPos, RayNormal = CastRay(Torso.Position, v.Direction, v.Length, {Character}, false)
			if RayHit then
				table.insert(RayData, {RayHit = RayHit, RayPos = RayPos, RayNormal = RayNormal})
			end
		end
		if #RayData > 0 then
			table.sort(RayData, (function(a, b)
				return ((Torso.Position - a.RayPos).magnitude < (Torso.Position - b.RayPos).magnitude)
			end))
			local RayInfo = RayData[1]
			local Direction = (Torso.CFrame + RayInfo.RayNormal * 2).p
			BodyGyro.cframe = CFrame.new(Torso.Position, Vector3.new(Direction.X, Torso.Position.Y, Direction.Z))
			if BodyGyro.maxTorque == Vector3.new(0, 0, 0) then
				for i, v in pairs(GetAllChildren(Character, {"BasePart"})) do
					if v.Name ~= "HumanoidRootPart" then
						table.insert(Parts, {Part = v, BrickColor = v.BrickColor})
						v.BrickColor = RayInfo.RayHit.BrickColor
						v.Transparency = ((v.Name == "Head" and 1) or 0.95)
					end
				end
				InvokeClient("DisableJump", true)
				InvokeClient("StopAnimation", Animations.IdlePose)
				InvokeClient("PlayAnimation", Animations.StealthPose)
			end
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		else
			if BodyGyro.maxTorque == Vector3.new(math.huge, math.huge, math.huge) then
				for i, v in pairs(Parts) do
					if v and v.Part and v.Part.Parent then
						v.Part.BrickColor = v.BrickColor
						v.Part.Transparency = 0
					end
				end
				Parts = {}
				InvokeClient("DisableJump", false)
				InvokeClient("StopAnimation", Animations.StealthPose)
				InvokeClient("PlayAnimation", Animations.IdlePose)
			end
			BodyGyro.maxTorque = Vector3.new(0, 0, 0)		
		end
		wait(Rate)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	InvokeClient("PlayAnimation", Animations.Release)
	Mesh.MeshId = MeshData.Crossbow
	Sounds.Fire:Play()
	Fire(Handle.Position, InvokeClient("MousePosition"))
	wait(FireRate)
	Mesh.MeshId = MeshData.CrossbowAndArrow
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.IdlePose)
	end)
	Spawn(function()
		SetUpPoseMonitor()
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyGyro") then
			v:Destroy()
		end
	end
	for i, v in pairs(Parts) do
		if v and v.Part and v.Part.Parent then
			v.Part.BrickColor = v.BrickColor
			v.Part.Transparency = 0
		end
	end
	Parts = {}
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ServerControl.OnServerInvoke = OnServerInvoke