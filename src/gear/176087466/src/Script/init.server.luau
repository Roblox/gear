--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

Equipped = false

MaxRange = 50

Damage = 5
ReloadTime = 0.01

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.SmoothPlastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Anchored = true
BasePart.CanCollide = false
BasePart.Locked = true

Laser = BasePart:Clone()
Laser.Name = "Laser"
Laser.BrickColor = BrickColor.new("Bright red")
Laser.Transparency = 0.25
Laser.Reflectance = 0.25
LaserMesh = Instance.new("CylinderMesh")
LaserMesh.Scale = Vector3.new(0.25, 1, 0.25)
LaserMesh.Parent = Laser

Blotch = BasePart:Clone()
Blotch.Name = "InkBlotch"
Blotch.Size = Vector3.new(1, 0.2, 1)
BlotchMesh = Instance.new("CylinderMesh")
BlotchMesh.Scale = Vector3.new(0.25, 0.25, 0.25)
BlotchMesh.Parent = Blotch

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or Humanoid.Health == 0 or not Tool.Enabled then
		return
	end
	if Mode == "Click" and Value.Down then
		Tool.Enabled = false
		local Mouse = Value.Mouse
		
		if LaserModel and LaserModel.Parent then
			for i, v in pairs(LaserModel:GetChildren()) do
				if v:IsA("BasePart") and v.Name == "Laser" then
					v:Destroy()
				end
			end
		end

		local OffsetRadius = 10
		local RandomizedOffset = (Vector3.new(math.random(-OffsetRadius, OffsetRadius), math.random(-OffsetRadius, OffsetRadius), math.random(-OffsetRadius, OffsetRadius)) * 0.1)
		local TargetPoint = (Mouse.Hit + RandomizedOffset)

		local BlackLaserStartingPosition = PositionProjectile(Handle, 0, -0.25, 0)
		BlackLaserStartingPosition = BlackLaserStartingPosition + Handle.CFrame.lookVector * (Handle.Size.Z / 2)
		local BlackLaserHit, BlackLaserPos = CastRay(BlackLaserStartingPosition.p, TargetPoint, "Really black")
		LaserHit(BlackLaserHit, BlackLaserPos, "Really black")
		
		local WhiteLaserStartingPosition = PositionProjectile(Handle, 0, -0.5, 0)
		WhiteLaserStartingPosition = WhiteLaserStartingPosition + Handle.CFrame.lookVector * (Handle.Size.Z / 2)
		local WhiteLaserHit, WhiteLaserPos = CastRay(WhiteLaserStartingPosition.p, (TargetPoint + (Handle.CFrame * CFrame.Angles(0, 0, math.pi/2)).lookVector * 0.5), "Institutional white")
		LaserHit(WhiteLaserHit, WhiteLaserPos, "Institutional white")

--		wait(ReloadTime)
		Tool.Enabled = true
	end
end)

function LaserHit(Hit, Position, Color)
	if not Hit or not LaserModel or not LaserModel.Parent then
		return
	end
	local character, humanoid = FindCharacterAncestor(Hit)
	if not humanoid then
		CreateInkBlotch(Hit, Position, Color)
	elseif humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
		Hit.BrickColor = BrickColor.new(Color)
		for i, v in pairs(Hit:GetChildren()) do
			if v:IsA("DataModelMesh") then
				if v:IsA("FileMesh") then
					v.TextureId = ""
				end
				local RGBColor = BrickColor.new(Color).Color
				v.VertexColor = Vector3.new((RGBColor.r), (RGBColor.g), (RGBColor.b))
			end
			for i, v in pairs(Hit.Parent:GetChildren()) do
				if v:IsA("Clothing") then
					v:Destroy()
				end
			end
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)
	end
end

function Round(Number, Round_Decimal)
	local Whole_Number, Decimal = math.modf(Number)
	return ((Decimal >= Round_Decimal and math.ceil(Number)) or (Decimal < Round_Decimal and math.floor(Number)))
end

function PartToTerrain(Part, Position, GridOffset, RoundInterval)
	local PartCFrame = CFrame.new(Position)
	local PX, PY, PZ = PartCFrame.X, PartCFrame.Y, PartCFrame.Z
	local PXToGrid = (Round((PX / GridOffset), RoundInterval) * GridOffset)
	local PYToGrid = (Round((PY / GridOffset), RoundInterval) * GridOffset)
	local PZToGrid = (Round((PZ / GridOffset), RoundInterval) * GridOffset)
	local RandomX, RandomY, RandomZ = math.random(1, 2), math.random(1, 2), math.random(1, 2)
	RandomX = ((RandomX == 1 and -2) or (RandomX == 2 and 2))
	RandomY = ((RandomY == 1 and -2) or (RandomY == 2 and 2))
	RandomZ = ((RandomZ == 1 and -2) or (RandomZ == 2 and 2))
	PXToGrid = ((PXToGrid > PX and (PXToGrid - 2)) or (PXToGrid < PX and (PXToGrid + 2)) or (PXToGrid + RandomX))
	PYToGrid = ((PYToGrid > PY and (PYToGrid - 2)) or (PYToGrid < PY and (PYToGrid + 2)) or (PYToGrid + RandomY))
	PZToGrid = ((PZToGrid > PZ and (PZToGrid - 2)) or (PZToGrid < PZ and (PZToGrid + 2)) or (PZToGrid + RandomZ))
	PX = ((((PX + 2) % GridOffset ~= 0) and PXToGrid) or PX)
	PY = ((((PY + 2) % GridOffset ~= 0) and PYToGrid) or PY)
	PZ = ((((PZ + 2) % GridOffset ~= 0) and PZToGrid) or PZ)
	Part.CFrame = CFrame.new(PX, PY, PZ)
end

function GetNormalId(Part, Hit)
	if Part:IsA("Terrain") then
		local Terrain = game:GetService("Workspace").Terrain
		local HitTerrain = (Vector3.new(Round(Hit.X, 0.5), Round(Hit.Y, 0.5), Round(Hit.Z, 0.5)) * 4)
		local CellPosition = Terrain:WorldToCell(HitTerrain)
		local FakePart = BasePart:Clone()
		FakePart.Size = Vector3.new(4, 4, 4)
		PartToTerrain(FakePart, Hit, 4, 0.5)
		Part = FakePart
	end
	local Point = Part.CFrame:pointToObjectSpace(Hit)
	local Size = (Part.Size / 2)
	if math.abs(Point.X - Size.X) < 0.01 then
		return Enum.NormalId.Right
	elseif math.abs(Point.X + Size.X) < 0.01 then
		return Enum.NormalId.Left
	elseif math.abs(Point.Y - Size.Y) < 0.01 then
		return Enum.NormalId.Top
	elseif math.abs(Point.Y + Size.Y) < 0.01 then
		return Enum.NormalId.Bottom
	elseif math.abs(Point.Z - Size.Z) < 0.01 then
		return Enum.NormalId.Back
	elseif math.abs(Point.Z + Size.Z) < 0.01 then
		return Enum.NormalId.Front
	else
		return Enum.NormalId.Front
	end
end

function CreateInkBlotch(Hit, Position, Color)
	local Surface = GetNormalId(Hit, Position)
	local Surfaces = {
		Left = CFrame.Angles(0, 0, (math.pi / 2)),
		Right = CFrame.Angles(math.pi, 0, -(math.pi / 2)),
		Front = CFrame.Angles(-(math.pi / 2), 0, 0),
		Back = CFrame.Angles((math.pi / 2), 0, 0),
		Top = CFrame.Angles(0, 0, 0),
		Bottom = CFrame.Angles(math.pi, 0, 0)
	}
	local BlotchClone = Blotch:Clone()
	BlotchClone.BrickColor = BrickColor.new(Color)
	Debris:AddItem(BlotchClone, 5)
	BlotchClone.Parent = LaserModel
	BlotchClone.CFrame = CFrame.new(Position)
	BlotchClone.CFrame = BlotchClone.CFrame * Surfaces[Surface.Name]
	local YLookVector = (BlotchClone.CFrame * CFrame.Angles((math.pi / 2), 0, 0)).lookVector
	BlotchClone.CFrame = BlotchClone.CFrame + YLookVector * ((BlotchClone.Size.Y / 2) - 0.075)
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
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

function PositionProjectile(handle, x, y, z)
	local HandleClone = handle:Clone()
	local HandleCloneY = HandleClone:Clone()
	HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * y
	local HandleCloneZ = HandleCloneY:Clone()
	HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * z
	local HandleCloneX = HandleCloneZ:Clone()
	HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * x
	return HandleCloneX.CFrame
end

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function CastRay(StartingPosition, EndPosition, Color)
	local Direction = CFrame.new(StartingPosition, EndPosition).lookVector
	local Hit, Pos = RayCast(StartingPosition, Direction, MaxRange, {Character, LaserModel})
	local RayLength = (StartingPosition - Pos).magnitude
	if not Hit and (StartingPosition - EndPosition).magnitude < MaxRange then
		RayLength = (StartingPosition - EndPosition).magnitude
	end
	local LaserClone = Laser:Clone()
	LaserClone.BrickColor = BrickColor.new(Color)
	LaserClone.Size = Vector3.new(LaserClone.Size.X, RayLength, LaserClone.Size.Z)
	if not LaserModel or not LaserModel.Parent or LaserModel.Name ~= "LaserModel" then
		if LaserModel and LaserModel.Parent then
			LaserModel:Destroy()
		end
		LaserModel = Instance.new("Model")
		LaserModel.Name = "LaserModel"
		RemoverClone = Remover:Clone()
		RemoverClone.Disabled = false
		RemoverClone.Parent = LaserModel
	end
	Debris:AddItem(LaserClone, 5)
	InvokeClient("SetTargetFilter", LaserModel)
	LaserClone.Parent = LaserModel
	if not LaserModel.Parent then
		LaserModel.Parent = game:GetService("Workspace")
	end
	Spawn(function()
		if LaserClone and LaserClone.Parent then
			for i = 1, 100 do
				if LaserClone and LaserClone.Parent then
					if LaserClone.Transparency >= 1 then
						break
					end
					LaserClone.Transparency = LaserClone.Transparency + 0.025
				end
				wait(0.001)
			end
			if LaserClone and LaserClone.Parent then
				LaserClone:Destroy()
			end
		end
	end)
	LaserClone.CFrame = CFrame.new(StartingPosition) + Direction * (RayLength / 2)
	LaserClone.CFrame = CFrame.new(LaserClone.Position, Pos) * CFrame.Angles((math.pi / 2), 0, 0)
	return Hit, Pos
end

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	Equipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)