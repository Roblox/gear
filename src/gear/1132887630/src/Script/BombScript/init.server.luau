Part = script.Parent
--Mesh = Part:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

OrigSize = Part.Size
--OrigScale = Mesh.Scale

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "rbxassetid://"

Creator = Part:WaitForChild("Creator")
PushForce = Part:WaitForChild("PushForce")
Damage = Part:WaitForChild("Damage")

StunScript = script:WaitForChild("StunScript")
Functions = require(script:WaitForChild("Functions"))

Sounds = {
	Splat = script:WaitForChild("Splat"),
}

function TweenVector(Start, Goal, Time)
	return (Vector3.new((Goal.X - Start.X), (Goal.Y - Start.Y), (Goal.Z - Start.Z)) / Time)
end

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Parent) and Creator.Value) or nil)
end

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetPlayersNearby(Radius)
	local Humanoids = {}
	local CreatorPlayer = GetCreator()
	if CreatorPlayer then
		local NegativeRegion = (Part.Position - Vector3.new(Radius, Radius, Radius))
		local PositiveRegion = (Part.Position + Vector3.new(Radius, Radius, Radius))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local IgnoreList = {((CreatorPlayer and CreatorPlayer.Character) or nil)}
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= CreatorPlayer and v.Character and v.Character.Parent and Functions.IsTeamMate(CreatorPlayer, v) then
				table.insert(IgnoreList, v.Character)
			end
		end
		local Parts = Functions.GetParts(Region, 500, IgnoreList)
		for i, v in pairs(Parts) do
			local character = v.Parent
			if character:IsA("Accessory") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(Humanoids, humanoid) then
				table.insert(Humanoids, humanoid)
			end
		end
	end
	return Humanoids
end

ScaleFrames = 20
Duration = 3
Scale = 0.5
for i = 1, ScaleFrames do
	local OrigCF = Part.CFrame
	local NewSize = (OrigSize + TweenVector(OrigSize, (OrigSize * Scale), ((Duration * ScaleFrames) / i)))
	Part.Size = NewSize
--	Mesh.Scale = ((NewSize / OrigSize) * OrigScale)
	Part.CFrame = (OrigCF + Vector3.new(0, (NewSize / 2), 0))
	wait()
end

wait(2)

Part.Transparency = 1
Part.Anchored = true
Part.CanCollide = false

Sound = Sounds.Splat:Clone()
Sound.Parent = Part
Sound:Play()

HitHumanoids = {}

function CoverScreen(player)
	local PumpkinSplatterImages = {183686598, 183686615, 183686632, 183686647, 183686670}
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if PlayerGui then
		local ScreenGui = Instance.new("ScreenGui") 
		ScreenGui.Name = "WatermelonSplatter"
		local MainFrame = Instance.new("Frame") 
		MainFrame.Name = "Splater"
		MainFrame.Position = UDim2.new(0, 0, 0, 0) 
		MainFrame.Size = UDim2.new(1, 0, 1, 0) 
		MainFrame.BackgroundColor = BrickColor.new(1, 1, 1)
		MainFrame.Transparency = 1
		MainFrame.BorderColor = BrickColor.new(1, 1, 1)
		MainFrame.Parent = ScreenGui
	
		local s = Instance.new("ImageLabel")
		local size = ((math.random() * 0.35) + 0.5)
		s.Size = UDim2.new(size, 0, size, 0)
		s.Position = UDim2.new((math.random() - (size / 2)), 0, (math.random() - (size / 2)),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Rotation = math.random(0, 360)
		s.Transparency = 1
		s.Image = (BaseUrl .. PumpkinSplatterImages[math.random(1, #PumpkinSplatterImages)])
		s.Parent = MainFrame
	
		Debris:AddItem(s, (5 + (math.random() * 2)))
	
		for i = 1, 3 do
			local s = Instance.new("ImageLabel")
			local size = ((math.random() * 0.2) + 0.1)
			s.Size = UDim2.new(size,0, size, 0)
			s.Position = UDim2.new((math.random() - (size / 2)), 0, (math.random() - (size / 2)), 0)
			s.SizeConstraint = Enum.SizeConstraint.RelativeXX
			s.Rotation = math.random(0, 360)
			s.Transparency = 1
			s.Image = (BaseUrl .. PumpkinSplatterImages[math.random(1, #PumpkinSplatterImages)])
			s.Parent = MainFrame
			Debris:AddItem(s, (3 + (math.random() * 6)))
		end
	
		Debris:AddItem(ScreenGui, 10)
		
		ScreenGui.Parent = PlayerGui		
	
	end
end

Radius = 20
Colors = {"Br. yellowish orange", "Wheat", Color3.fromRGB(218, 106, 25), Color3.fromRGB(255, 133, 10)}
for i = 1, 50 do
	local Splatter = Instance.new("Part")
	Splatter.Name = "PumpkinSplatter"
	local RandomColor = Colors[math.random(1, #Colors)]
	if typeof(RandomColor) == "string" then
		Splatter.Color = BrickColor.new(RandomColor).Color
	elseif typeof(RandomColor) == "Color3" then
		Splatter.Color = RandomColor
	end
	Splatter.Material = Enum.Material.Plastic
	Splatter.Shape = Enum.PartType.Block
	Splatter.TopSurface = Enum.SurfaceType.Smooth
	Splatter.BottomSurface = Enum.SurfaceType.Smooth
	Splatter.Size = Vector3.new(0.2, 0.2, 0.2)
	Splatter.CanCollide = true
	Debris:AddItem(Splatter, 2)
	Splatter.Parent = game:GetService("Workspace")
	Splatter.CFrame = (Part.CFrame * CFrame.new((math.random(Radius, Radius) / 100), (math.random(Radius, Radius) / 100), (math.random(Radius, Radius) / 100)))
	Splatter.Velocity = (CFrame.new(0 , 0, 0) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360))).lookVector * math.random(3, 12))
end

CreatorPlayer = GetCreator()
if CreatorPlayer then
	Humanoids = GetPlayersNearby(6)
	for i, v in pairs(Humanoids) do
		local Humanoid = v
		local Character = Humanoid.Parent
		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		local Player = Players:GetPlayerFromCharacter(Character)
		if (not Player or (Player and Player ~= CreatorPlayer and not IsTeamMate(CreatorPlayer, Player))) and Humanoid and Humanoid.Health > 0 and RootPart then
			RootPart.Velocity = (CFrame.new(Part.Position, RootPart.Position).lookVector * PushForce.Value)
			
			local StunScriptCopy = StunScript:Clone()
			StunScriptCopy.Disabled = false
			StunScriptCopy.Parent = Character
			
			if Player then
				CoverScreen(Player)
			end
			
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, CreatorPlayer)
			Humanoid:TakeDamage(Damage.Value)
		end
	end
end

wait(3)

Part:Destroy()