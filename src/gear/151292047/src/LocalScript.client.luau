--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
SpecialReady = Tool:WaitForChild("SpecialReady")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

FiringSound = Handle:WaitForChild("FiringSound")
SwingingSound = Handle:WaitForChild("SwingingSound")
RisingSound = Handle:WaitForChild("RisingSound")

ToolGrip = CFrame.new(0, -0.25, 0, 0.999993622, -0, -0.00356361363, 0, 1, -0, 0.00356361363, 0, 0.999993622)

Firing = false

BLOXikins = {132922951, 132923435, 132923387, 132923132, 132923240, 132923310, 132923625, 132923762, 132923833, 132923878, 132923921, 132923524, 133519820, 133520439, 133520293, 133520174, 133520394, 133520230, 133520348, 133520071, 133872999, 134043004, 134043071, 134043123, 134043181, 134043336, 134043361, 134043402, 134043441, 133873051, 132923064, 138932292, 144294484, 144294526, 133560053}
BLOXikinsInserted = {}

for i, v in pairs(BLOXikins) do
	local BLOXikinModel = InsertService:LoadAsset(v)
	local BLOXikin = BLOXikinModel:GetChildren()[1]
	local BLOXikinName = BLOXikin.Name
	BLOXikin = BLOXikin:FindFirstChild("Handle"):Clone()
	BLOXikin.Name = BLOXikinName
	table.insert(BLOXikinsInserted, BLOXikin)
	BLOXikinModel:Destroy()
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
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

function MakeCircle(Diameter, Consistency, Size, Position)
	local Parts = {}
	for i = 1, 360, Consistency do
		local Part = Instance.new("Part")
		Part.FormFactor = Enum.FormFactor.Custom
		Part.Size = Size
		Part.TopSurface = Enum.SurfaceType.Smooth
		Part.BottomSurface = Enum.SurfaceType.Smooth
		Part.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, Diameter)
		table.insert(Parts, Part)
	end
	return Parts
end

function TagHumanoid(Humanoid, Player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Name = "creator"
	creator_tag.Value = Player
	Debris:AddItem(creator_tag, 2)
	creator_tag.Parent = Humanoid
	return creator_tag
end

function UntagHumanoid(Humanoid)
	for i, v in pairs(Humanoid:GetChildren()) do
		if v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Fire(TargetPoint, Damage, StartingPosition)
	local Offset = 1
	
	local HandleClone = Handle:Clone()
	local HandleCloneY = HandleClone:Clone()
	HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((HandleClone.Size.Y / 2) + math.random(-Offset, Offset))
	local HandleCloneZ = HandleCloneY:Clone()
	HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) + 0.25)
	local HandleCloneX = HandleCloneZ:Clone()
	HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * ((HandleClone.Size.X / 2) + math.random(-Offset, Offset))
	
	local BLOXikin = BLOXikinsInserted[math.random(1, #BLOXikinsInserted)]:Clone()
	BLOXikin.CanCollide = false
	BLOXikin.Locked = true
	BLOXikin.Name = BLOXikin.Name .. "Projectile"
	local Fire = Instance.new("Fire")
	Fire.Color = BrickColor.new("Really red").Color
	Fire.SecondaryColor = Fire.Color
	Fire.Heat = 10
	Fire.Size = 5
	Fire.Parent = BLOXikin
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Parent = BLOXikin
	BLOXikin.Touched:connect(function(Hit)
		if Hit and Hit.Parent then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character and humanoid and character ~= Character then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
				BLOXikin:Destroy()
			end
		end
	end)
	Debris:AddItem(BLOXikin, 5)
	BLOXikin.Parent = game:GetService("Workspace")
	local BLOXikinCFrame = ((StartingPosition and StartingPosition) or HandleCloneX.CFrame)
	BLOXikin.CFrame = BLOXikinCFrame
	BLOXikin.CFrame = CFrame.new(BLOXikinCFrame.p, ((TargetPoint and TargetPoint) or HandleCloneX.Position + Torso.CFrame.lookVector))
	BodyVelocity.velocity = BLOXikin.CFrame.lookVector * 50
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 and Torso then
		return
	end
	Tool.Grip = ToolGrip
	if not Tool.Enabled then
		wait(3)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and not Firing then
			
			Firing = true
			Tool.Enabled = false
			Tool.GripUp = Vector3.new(0, 1, 0.25)
			Fire(Humanoid.TargetPoint, 15, nil)
			local Play = Instance.new("BoolValue")
			Play.Name = "Play"
			Play.Parent = FiringSound
			wait(0.5)
			Tool.Grip = ToolGrip
			wait(0.5)
			Firing = false
			Tool.Enabled = true
			
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" and Tool.Enabled and not Firing and SpecialReady.Value then
			SpecialReady.Value = false
			Firing = true
			OriginalWalkSpeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = 0
			Tool.Enabled = false
			local Play = Instance.new("BoolValue")
			Play.Name = "Play"
			Play.Parent = SwingingSound
			for i = 1, 100 do
				if not Firing then
					break
				end
				Theta = ((i % 10) * (math.pi / 10))
				Tool.GripRight = Vector3.new(0, -math.sin(Theta), math.cos(Theta)) 
				Tool.GripUp = Vector3.new(0, math.cos(Theta), math.sin(Theta))								
				Fire(nil, 10, nil)
				wait() 
			end
			local Stop = Instance.new("BoolValue")
			Stop.Name = "Stop"
			Stop.Parent = SwingingSound
			Tool.Grip = ToolGrip
			Humanoid.WalkSpeed = OriginalWalkSpeed
			OriginalWalkSpeed = nil
			Firing = false
			Tool.Enabled = true
		elseif Key == "e" and Tool.Enabled and not Firing and SpecialReady.Value then
			Firing = true
			OriginalWalkSpeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = 0
			Tool.Enabled = false
			local Rate = 0.1
			for i = Rate, (((Handle.Size.Y + 1.125) / 2) / Rate) do
				if not Firing then
					break
				end
				Tool.GripPos = Vector3.new(Tool.GripPos.X, (Tool.GripPos.Y + 0.05), Tool.GripPos.Z)
				wait()
			end
			local Hit, EndPosition = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
			if Hit and Firing then
				SpecialReady.Value = false
				local Parts = MakeCircle(3, 60, Vector3.new(1, 1, 1), EndPosition)
				for i, v in pairs(Parts) do
					v.BrickColor = BrickColor.new("Bright orange")
					v.Material = Enum.Material.Granite
					v.Anchored = true
					v.Size = Vector3.new(4, 4, 4)
					local PartCFrame = v.CFrame
					Debris:AddItem(v, 15)
					v.Parent = game:GetService("Workspace")
					v.CFrame = PartCFrame * CFrame.Angles(math.random(), math.random(),math.random())
				end
				local Play = Instance.new("BoolValue")
				Play.Name = "Play"
				Play.Parent = RisingSound
				for i = 1, 100 do
					if not Firing then
						break
					end
					local FirePosition = CFrame.new(EndPosition) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0) * CFrame.new(0, 0, 5)
					Fire(FirePosition.p + Vector3.new(0, 1, 0), 20, FirePosition)
					wait()
				end
				local Stop = Instance.new("BoolValue")
				Stop.Name = "Stop"
				Stop.Parent = RisingSound
			else
				Tool.Grip = ToolGrip
				Humanoid.WalkSpeed = OriginalWalkSpeed
				OriginalWalkSpeed = nil
				Firing = false
				Tool.Enabled = true
			end
			if Hit then
				Tool.Grip = ToolGrip
				Humanoid.WalkSpeed = OriginalWalkSpeed
				OriginalWalkSpeed = nil
				Firing = false
				Tool.Enabled = true
			end
		end
	end)
end

function Unequipped(Mouse)
	Firing = false
	local Stop = Instance.new("BoolValue")
	Stop.Name = "Stop"
	Stop.Parent = SwingingSound
	local Stop = Instance.new("BoolValue")
	Stop.Name = "Stop"
	Stop.Parent = RisingSound
	if OriginalWalkSpeed then
		Humanoid.WalkSpeed = OriginalWalkSpeed
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)