--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")

Player = nil
Character = nil
Humanoid = nil

-- Returns a character ancestor and its Humanoid, or nil
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

function CastLaser(StartPosition, Direction, MaxDistance, Ignore)
	
	local function RayCast(Pos, Dir, Max, IgnoreList)
		return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
	end

	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "CloverLaser"
	LaserPart.Transparency = 0.000001
	LaserPart.FormFactor = Enum.FormFactor.Custom
	LaserPart.TopSurface = Enum.SurfaceType.Smooth
	LaserPart.BottomSurface = Enum.SurfaceType.Smooth
	LaserPart.Material = Enum.Material.SmoothPlastic
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset?id=149229831"
	Mesh.TextureId = "http://www.roblox.com/asset?id=149229890"
	Mesh.Scale = Vector3.new(3, 3, (Distance * 25 - (Distance * 2)))
	Mesh.Parent = LaserPart
	Debris:AddItem(LaserPart, 1)
	LaserPart.Parent = Character
	LaserPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))
	Spawn(function()
		for i = 1, 20 do
			wait(0.05)
			LaserPart.Transparency = LaserPart.Transparency + 0.05
		end
	end)
	
	return Hit, EndPosition, ChosenColor
	
end

function Fire()
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false
		
		PlaySound.Value = "22968437"
		
		local StartingPosition = Handle.Position + Handle.CFrame.lookVector * (Handle.Size.Z / 2)
		
		local HandleClone = Handle:Clone()
		local HandleCloneY = HandleClone:Clone()
		HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
		HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((Handle.Size.Y / 2) - 0.5)
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) - 0.425)	
		
		local Hit, Pos = CastLaser(HandleCloneZ.CFrame.p, (Humanoid.TargetPoint - StartingPosition), 100, {Character})
		
		local character, humanoid = FindCharacterAncestor(Hit)

		if character and character.Parent and humanoid and humanoid.Parent then
			local Clover = Instance.new("Part")
			Clover.Name = "CloverLaser"
			Clover.FormFactor = Enum.FormFactor.Custom
			Clover.TopSurface = Enum.SurfaceType.Smooth
			Clover.BottomSurface = Enum.SurfaceType.Smooth
			Clover.Material = Enum.Material.SmoothPlastic
			Clover.CanCollide = false
			Clover.Locked = true
			Clover.Size = Vector3.new(0.2, 0.2, 0.2)
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = "http://www.roblox.com/asset?id=149229831"
			Mesh.TextureId = "http://www.roblox.com/asset?id=149229890"
			Mesh.Scale = Vector3.new(3, 3, 3)
			Mesh.Parent = Clover
			Debris:AddItem(Clover, 10)
			Clover.Parent = character
			local Weld = Instance.new("Weld")
			Weld.Part0 = Hit
			Weld.Part1 = Clover
			Weld.Parent = Clover
			local StickCF = CFrame.new(Pos, Handle.Position) * CFrame.new(0, 0, -1)
			StickCF = StickCF - CFrame.new(Pos, Handle.Position).lookVector * ((Handle.Size.z / 2) - (Clover.Size.z / 1))
			Weld.C1 = StickCF:inverse() * Hit.CFrame
			local creator_tag = Instance.new("ObjectValue")
			creator_tag.Name = "creator"
			creator_tag.Value = Player
			Debris:AddItem(creator_tag, 2)
			creator_tag.Parent = humanoid
			humanoid:TakeDamage(10)
		end

		wait(1)

		Tool.Enabled = true
	end
end

function OnEquipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not Tool.Enabled then
		wait(0.5)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		Fire()
	end)
end

function OnUnequipped()
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)