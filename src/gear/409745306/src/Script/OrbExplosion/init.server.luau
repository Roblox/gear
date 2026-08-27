--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

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

Functions = require(script:WaitForChild("Functions"))

Creator = script:WaitForChild("Creator")
OriginPoint = script:WaitForChild("OriginPoint")

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function GetPlayersNearby(Position, Radius)
	local Humanoids = {}
	local NegativeRegion = (Position - Vector3.new(Radius, Radius, Radius))
	local PositiveRegion = (Position + Vector3.new(Radius, Radius, Radius))
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
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(Humanoids, humanoid) then
			table.insert(Humanoids, humanoid)
		end
	end
	return Humanoids
end

function TweenVector(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = (Vector3.new((Goal.X - Object[Property].X), (Goal.Y - Object[Property].Y), (Goal.Z - Object[Property].Z)) / Time)
	for i = 1, Time do
		local OriginalCFrame
		if Object:IsA("BasePart") and Property == "Size" then
			OriginalCFrame = Object.CFrame
		end
		Object[Property] = (Object[Property] + Increment)
		if OriginalCFrame then
			Object.CFrame = (OriginalCFrame + Vector3.new(0, (Increment / 2), 0))
		end
		wait()
	end
	return true
end

function TweenNumber(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = ((Goal - Object[Property]) / Time)
	for i = 1, Time do
		Object[Property] = (Object[Property] + Increment)
		wait()
	end
	return true
end

CreatorPlayer = GetCreator()

local OrbPart = BasePart:Clone()
OrbPart.Name = "Effect"
OrbPart.BrickColor = BrickColor.new("Really red")
OrbPart.Transparency = 0.125
OrbPart.Material = Enum.Material.Neon
OrbPart.Shape = Enum.PartType.Ball
OrbPart.Size = Vector3.new(1, 1, 1)
OrbPart.Anchored = true
OrbPart.CanCollide = false
OrbMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.Sphere,
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(0, 0, 0),
	Offset = Vector3.new(0, 0, 0),
	Parent = OrbPart,
}
Debris:AddItem(OrbPart, 10)
local OriginPoint = OriginPoint.Value
OrbPart.CFrame = CFrame.new(OriginPoint)
OrbPart.Parent = game:GetService("Workspace")
Radius = 20
Spawn(function()
	Spawn(function()
		local HumanoidsHit = {}
		while OrbPart and OrbPart.Parent do
			local PlayersNearby = GetPlayersNearby(OriginPoint, (OrbMesh.Scale.Y * 1.125))
			for i, v in pairs(PlayersNearby) do
				if not Functions.CheckTableForInstance(HumanoidsHit, v) then
					table.insert(HumanoidsHit, v)
					Functions.UntagHumanoid(v)
					Functions.TagHumanoid(v, CreatorPlayer)
					v:TakeDamage(40)
				end
			end
			wait(0.25)
		end
	end)
	TweenVector(OrbMesh, "Scale", (OrbMesh.Scale * (Radius * 1)), 0.5)
	TweenNumber(OrbPart, "Transparency", 1, 0.5)
	wait(0.5)
	script:Destroy()
end)