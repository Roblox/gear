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
	
	local Colors = {"Bright green", "Bright yellow", "Bright violet"}

	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local ChosenColor = Colors[math.random(1, #Colors)]
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "Laser"
	LaserPart.BrickColor = BrickColor.new(ChosenColor)
	LaserPart.Transparency = 0.25
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
	Spawn(function()
		for i = 1, 75 do
			wait(0.01)
			LaserPart.Transparency = LaserPart.Transparency + 0.05
		end
	end)
	LaserPart.Parent = Character
	
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
		HandleCloneY.CFrame = HandleCloneY.CFrame + HandleCloneY.CFrame.lookVector * ((Handle.Size.Y / 2) - 0.6)
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) - 0.20)	
		
		local Hit, Pos, BrickColorChosen = CastLaser(HandleCloneZ.CFrame.p, (Humanoid.TargetPoint - StartingPosition), 100, {Character})
		
		local character, humanoid = FindCharacterAncestor(Hit)

		if character and character.Parent and humanoid and humanoid.Parent then
			humanoid:TakeDamage(5)
		end

		wait(0.1)

		Tool.Enabled = true
	end
end

function OnEquipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not Tool.Enabled then
		wait(1)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		MouseDown = true
		while MouseDown do
			Fire()
			wait()
		end
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