--Made by Luckymaxer

MouseDown = false

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")

Necklace = InsertService:LoadAsset(147198993):GetChildren()[1]:Clone()

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
	LaserPart.Name = "Laser"
	LaserPart.BrickColor = BrickColor.new("Pastel Blue")
	LaserPart.Transparency = 0.5
	LaserPart.FormFactor = Enum.FormFactor.Custom
	LaserPart.TopSurface = Enum.SurfaceType.Smooth
	LaserPart.BottomSurface = Enum.SurfaceType.Smooth
	LaserPart.Material = Enum.Material.SmoothPlastic
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	LaserPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))
	Debris:AddItem(LaserPart, 1)
	LaserPart.Parent = Character

	return Hit, EndPosition, LaserPart
	
end

function Fire()
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false
		
		PlaySound.Value = "11944350"
		
		local StartingPosition = Handle.Position + Handle.CFrame.lookVector * (Handle.Size.Z / 2)
		
		local HandleClone = Handle:Clone()
		local HandleCloneY = HandleClone:Clone()
		HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
		HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((Handle.Size.Y / 2) - 0.25)
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) - 0.25)
		
		local Hit, Pos, Laser = CastLaser(HandleCloneZ.CFrame.p, (Humanoid.TargetPoint - StartingPosition), 25, {Character})

		local character, humanoid = FindCharacterAncestor(Hit)

		if character and character.Parent and humanoid and humanoid.Parent and character:FindFirstChild("Head") then

			if not character:FindFirstChild(Necklace.Name) then
				local NecklaceClone = Necklace:Clone()
				Debris:AddItem(NecklaceClone, 20)
				NecklaceClone.Parent = character
			end
			
			for i = 1, math.random(5, 10) do
				for ii = 1, math.random(10, 25) do
					local PlayerHead = character.Head
					if PlayerHead then
						local Part = Instance.new("Part")
						Part.FormFactor = Enum.FormFactor.Custom
						Part.Size = Vector3.new(0.2, 0.2, 0.2)
						Part.TopSurface = Enum.SurfaceType.Smooth
						Part.BottomSurface = Enum.SurfaceType.Smooth
						Part.BrickColor = BrickColor.new(math.random(), math.random(), math.random())
						Part.Name = "Confetti"
						Part.CanCollide = false
						Part.Velocity = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) * 10
						local Mesh = Instance.new("SpecialMesh")
						Mesh.MeshType = Enum.MeshType.Brick
						Mesh.Scale = Vector3.new(1, 0.5, 1)
						Mesh.Parent = Part
						Debris:AddItem(Part, 5)
						Part.Parent = character
						local PlayerHeadClone = PlayerHead:Clone()
						local PlayerHeadCloneY = PlayerHeadClone:Clone()
						PlayerHeadCloneY.CFrame = PlayerHeadCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
						PlayerHeadCloneY.CFrame = PlayerHeadCloneY.CFrame + PlayerHeadCloneY.CFrame.lookVector * (PlayerHeadCloneY.Size.Y * 2)
						Part.CFrame = PlayerHeadCloneY.CFrame * CFrame.Angles(-math.rad(90), 0, 0)
					end
				end
				wait(0.01)
			end

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
		wait(3)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		MouseDown = true
		Fire()
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function OnUnequipped()
	MouseDown = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)