--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")
SphereScript = Tool:WaitForChild("SphereScript")
SpecialReady = Tool:WaitForChild("SpecialReady")

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

function CastLaser(StartPosition, Direction, MaxDistance, Ignore)
	
	local function RayCast(Pos, Dir, Max, IgnoreList)
		return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
	end

	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "Laser"
	LaserPart.Transparency = 0.000001
	LaserPart.FormFactor = Enum.FormFactor.Custom
	LaserPart.TopSurface = Enum.SurfaceType.Smooth
	LaserPart.BottomSurface = Enum.SurfaceType.Smooth
	LaserPart.Material = Enum.Material.SmoothPlastic
	LaserPart.BrickColor = BrickColor.new("New Yeller")
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.35, 0.35, Distance)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Brick
	Mesh.Scale = Vector3.new(1, 1, 1)
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
	
	return Hit, EndPosition
	
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
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) - 0)	
		
		local Hit, Pos = CastLaser(HandleCloneZ.CFrame.p, (Humanoid.TargetPoint - StartingPosition), 100, {Character})
		
		local character, humanoid = FindCharacterAncestor(Hit)

		if character and character.Parent and humanoid and humanoid.Parent then
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
	Torso = Character:WaitForChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not Tool.Enabled then
		wait(0.5)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		Fire()
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" and SpecialReady.Value then
			SpecialReady.Value = false
			Sphere = Instance.new("Part")
			Sphere.Name = "Sphere"
			Sphere.TopSurface = Enum.SurfaceType.Smooth
			Sphere.BottomSurface = Enum.SurfaceType.Smooth
			Sphere.Material = Enum.Material.Plastic
			Sphere.Shape = Enum.PartType.Ball
			Sphere.FormFactor = Enum.FormFactor.Custom
			Sphere.Size = Vector3.new(6, 6, 6)
			Sphere.CanCollide = false
			Sphere.Locked = true
			Sphere.Transparency = 0.5
			Sphere.BrickColor = BrickColor.new("Really red")
			Sphere.CFrame = Torso.CFrame
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.D = 100
			BodyPosition.maxForce = Vector3.new(9e+999, 9e+999, 9e+999)
			BodyPosition.Parent = Sphere
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.D = 250
			BodyGyro.P = 5000
			BodyGyro.maxTorque = Vector3.new(0, 9e+999, 0)
			BodyGyro.Parent = Sphere
			SphereScriptClone = SphereScript:Clone()
			SphereScriptClone.Disabled = false
			Creator = Instance.new("ObjectValue")
			Creator.Name = "creator"
			Creator.Value = Player
			Creator.Parent = SphereScriptClone
			SphereScriptClone.Parent = Sphere
			Debris:AddItem(Sphere, 20)
			Sphere.Parent = Character
			Spawn(function()
				while Sphere and Sphere.Parent and BodyPosition and BodyPosition.Parent and BodyGyro and BodyGyro.Parent do
					BodyPosition.position = Torso.Position
					BodyGyro.cframe = BodyGyro.cframe * CFrame.Angles(0, 0.1, 0)
					wait()
				end
			end)
			local Parts = MakeCircle(3, 60, Vector3.new(1, 1, 1), Torso.Position)
			for i, v in pairs(Parts) do
				v.Name = "Note"
				v.CanCollide = false
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = "http://www.roblox.com/asset?id=151980686"
				Mesh.TextureId = "http://www.roblox.com/asset?id=151980715"
				Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
				Mesh.Parent = v
				v.CFrame = CFrame.new(v.Position, Torso.Position)
				v.CFrame = v.CFrame * CFrame.Angles(0, math.pi / 2, 0)
				local CF = v.CFrame
				v.Parent = Sphere
				local Weld = Instance.new("Weld")
				Weld.Part0 = Sphere
				Weld.Part1 = v
				Weld.Parent = v
				Weld.C0 = Sphere.CFrame:inverse()
				Weld.C1 = CF:inverse()
			end
		end
	end)
end

function OnUnequipped()
	if Sphere and Sphere.Parent then
		Sphere:Destroy()
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)