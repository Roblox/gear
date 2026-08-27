--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Pose = Tool:WaitForChild("Pose")

LaserSound = Handle:WaitForChild("LaserSound")

LaserModelRemoval = script:WaitForChild("LaserModelRemoval")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 5
ReloadTime = 0.1
NeckChangedConnections = {}
MouseDown = false

LaserRange = 35
LaserOffset = 100

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

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function CastLaser(Mouse, StartPosition, Direction, MaxDistance, Ignore, Color)

	local LaserModelName = Player.Name .. "_LaserModel"
	local LaserModel = game:GetService("Workspace"):FindFirstChild(LaserModelName)
	if not LaserModel then
		LaserModel = Instance.new("Model")
		LaserModel.Name = LaserModelName
		local LaserModelRemovalClone = LaserModelRemoval:Clone()
		LaserModelRemovalClone.Disabled = false
		LaserModelRemovalClone.Parent = LaserModel
		LaserModel.Parent = game:GetService("Workspace")
	end
	table.insert(Ignore, LaserModel)
	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "Laser"
	LaserPart.BrickColor = BrickColor.new(Color)
	LaserPart.Transparency = 0.5
	LaserPart.FormFactor = Enum.FormFactor.Custom
	LaserPart.TopSurface = Enum.SurfaceType.Smooth
	LaserPart.BottomSurface = Enum.SurfaceType.Smooth
	LaserPart.Material = Enum.Material.SmoothPlastic
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	Debris:AddItem(LaserPart, 1)
	LaserPart.Parent = LaserModel
	LaserPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))
	Mouse.TargetFilter = LaserModel
	Spawn(function()
		for i = 1, 20 do
			wait(0.05)
			LaserPart.Transparency = LaserPart.Transparency + 0.05
		end
	end)	
	
	return Hit, EndPosition
	
end

function StopLaser()
	LaserSound:Stop()
	MouseDown = false
	if Neck and Neck.Parent then
		Neck.C1 = NeckOrigin
	end
end

function FireLaser(Mouse)
	IgnoreHeadChange = true
	local LastHeadRotation = Neck.C1
	Neck.C1 = NeckOrigin
	local HeadOrigin = Head:Clone()
	local Base = Neck.Part0.Position + (Neck.C0.p * 1)
	local YVector = (Mouse.Hit.p + Mouse.Hit.lookVector)
	local Set = CFrame.new(Base, YVector)
	local Offset = Set:toObjectSpace(Torso.CFrame * Neck.C0)
	local PosX, PosY, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Offset:components()
	Neck.C1 = CFrame.new(NeckOrigin.p.x, NeckOrigin.p.y, NeckOrigin.p.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	local HeadClone = Head:Clone()
	local HeadCloneY = HeadClone:Clone()
	HeadCloneY.CFrame = HeadCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HeadCloneY.CFrame = HeadCloneY.CFrame + HeadCloneY.CFrame.lookVector * 0.2
	local HeadCloneZ = HeadCloneY:Clone()
	HeadCloneZ.CFrame = HeadCloneZ.CFrame + HeadClone.CFrame.lookVector * (HeadClone.Size.z / 2)
	local HeadRotationCheck = false
	if math.abs((Head.Position - Torso.Position).magnitude) >= 1.25 then
		HeadRotationCheck = true
	else
		Neck.C1 = LastHeadRotation
	end
	IgnoreHeadChange = false
	if HeadRotationCheck and (math.acos((Mouse.Hit.p - HeadOrigin.Position).unit:Dot(HeadOrigin.CFrame.lookVector)) <= (math.pi / 2)) then
		for i, v in pairs(NeckChangedConnections) do
			v:disconnect()
		end
		NeckChangedConnections = {}
		Spawn(function()
			Tool.Enabled = false
			local FaceplateClone = Faceplate:Clone()
			local FaceplateCloneY = FaceplateClone:Clone()
			FaceplateCloneY.CFrame = FaceplateCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			FaceplateCloneY.CFrame = FaceplateCloneY.CFrame + FaceplateCloneY.CFrame.lookVector * ((FaceplateClone.Size.Y / 2) - 0.7)
			local FaceplateCloneZ = FaceplateCloneY:Clone()
			FaceplateCloneZ.CFrame = FaceplateCloneZ.CFrame + FaceplateClone.CFrame.lookVector * ((FaceplateClone.Size.Z / 2) + 0)
			local FaceplateCloneX = FaceplateCloneZ:Clone()
			FaceplateCloneX.CFrame = FaceplateCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
			FaceplateCloneX.CFrame = FaceplateCloneX.CFrame - FaceplateCloneX.CFrame.lookVector * ((FaceplateClone.Size.X / 2) - ((FaceplateClone.Size.X / 2) + 0.25))
			local TargetPoint = Mouse.Hit.p + Vector3.new((math.random(-LaserOffset, LaserOffset) / LaserOffset), (math.random(-LaserOffset, LaserOffset) / LaserOffset), (math.random(-LaserOffset, LaserOffset) / LaserOffset))
			local Hit, EndPosition = CastLaser(Mouse, FaceplateCloneX.Position, (TargetPoint - FaceplateCloneX.Position), LaserRange, {Character}, "Bright red")
			if Hit and Hit.Parent then
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character and character ~= Character and humanoid and humanoid.Health > 0 then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
				end
			end
			wait(ReloadTime)
			Tool.Enabled = true
		end)
		local NeckChanged
		NeckChanged = Neck.Changed:connect(function(Property)
			if Property == "C0" or Property == "C1" and not IgnoreHeadChange then
				for i, v in pairs(NeckChangedConnections) do
					v:disconnect()
				end
				NeckChangedConnections = {}
			end
		end)
		table.insert(NeckChangedConnections, NeckChanged)
		Delay(1, function()
			if NeckChanged.connected then
				Neck.C1 = NeckOrigin
				StopLaser()
			end
		end)
	else
		IgnoreHeadChange = true
		Neck.C1 = LastHeadRotation
		IgnoreHeadChange = false
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	Neck = Torso:FindFirstChild("Neck")
	NeckOrigin = Neck.C1
	if not Character or not Humanoid or not Head or not Torso or not Neck then
		return
	end
	wait()
	PoseAnim = Humanoid:LoadAnimation(Pose)
	if PoseAnim then
		PoseAnim:Play()
	end
	Faceplate = Handle:Clone()
	Handle.Transparency = 1
	FaceplateWeld = Instance.new("Weld")
	FaceplateWeld.Part0 = Head
	FaceplateWeld.Part1 = Faceplate
	FaceplateWeld.C1 = FaceplateWeld.C1 + Vector3.new(0, -0.18, 0.05)
	FaceplateWeld.Parent = Faceplate
	Faceplate.Parent = Character
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and Humanoid.Health > 0 then
			MouseDown = true
			Spawn(function()
				LaserSound:Play()
				while MouseDown do
					LaserSound.Volume = (((math.sin(tick() * 3) + 1) * 0.25) + 0.25)
					FireLaser(Mouse)
					wait()
				end
				LaserSound:Stop()
			end)
		end
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function Unequipped()
	Handle.Transparency = 0
	StopLaser()
	if Faceplate and Faceplate.Parent then
		Faceplate:Destroy()
	end
	if PoseAnim then
		PoseAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)