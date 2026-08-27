--Made by Luckymaxer

Pumpkin = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PointLight = Pumpkin:WaitForChild("PointLight")

Creator = Pumpkin:WaitForChild("Creator").Value
BlackoutScript = script:WaitForChild("BlackoutScript")

StinkMeshes = {181316184, 181316202, 181316221, 181316236}
StinkTexture = 179155958

StinkLine = Instance.new("Part")
StinkLine.Name = "StinkLine"
StinkLine.Shape = Enum.PartType.Block
StinkLine.Material = Enum.Material.Plastic
StinkLine.TopSurface = Enum.SurfaceType.Smooth
StinkLine.BottomSurface = Enum.SurfaceType.Smooth
StinkLine.FormFactor = Enum.FormFactor.Custom
StinkLine.Size = Vector3.new(0.25, 1, 0.25)
StinkLine.CanCollide = false
StinkLine.Locked = true
StinkLine.Anchored = false
StinkMesh = Instance.new("SpecialMesh")
StinkMesh.MeshType = Enum.MeshType.FileMesh
StinkMesh.TextureId = tostring("http://www.roblox.com/asset?id=" .. StinkTexture)
StinkMesh.Scale = Vector3.new(1, 1, 1)
StinkMesh.Parent = StinkLine

StinkLines = {
	{Position = {X = -0.5, Z = 0}},
	{Position = {X = -0.25, Z = 0.25}},
	{Position = {X = 0, Z = 0.25}},
	{Position = {X = -0.25, Z = -0.25}},
	{Position = {X = 0, Z = -0.25}},
	{Position = {X = 0.25, Z = 0}},
	{Position = {X = 0.5, Z = 0}}
}

MaxRadius = 5

wait(1.5)

PointLight.Range = MaxRadius
PointLight.Enabled = true

for i, v in pairs(Pumpkin:GetChildren()) do
	if v:IsA("BasePart") and v.Name == "StinkLine" then
		v:Destroy()
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

function EmitStink()
	local StinkLineChosen = StinkLines[math.random(1, #StinkLines)]
	if not StinkLineChosen.StinkLine or not StinkLineChosen.StinkLine.Parent then
		local NewStinkLine = StinkLine:Clone()
		NewStinkLine:FindFirstChild("Mesh").MeshId = tostring("http://www.roblox.com/asset?id=" .. StinkMeshes[math.random(1, #StinkMeshes)])
		local Weld = Instance.new("Weld")
		Weld.Parent = NewStinkLine
		Weld.Part0 = NewStinkLine
		Weld.Part1 = Pumpkin
		local Rotation = math.random(1, 2)
		Weld.C1 = CFrame.new(StinkLineChosen.Position.X, ((Pumpkin.Size.Y / 2)), StinkLineChosen.Position.Z) * CFrame.Angles(0, ((Rotation == 1 and 0) or math.pi), 0)
		StinkLineChosen.StinkLine = NewStinkLine
		StinkLineChosen.Weld = Weld
		NewStinkLine.Parent = Pumpkin
	else
		if StinkLineChosen.Weld.C1.Y > 1.5 then
			if StinkLineChosen.StinkLine and StinkLineChosen.StinkLine.Parent then
				StinkLineChosen.StinkLine:Destroy()
			end
		else
			StinkLineChosen.Weld.C1 = StinkLineChosen.Weld.C1 + Vector3.new(0, (math.random(1, 25) * 0.01), 0)
		end
	end
end

function GetPlayersNearby(Radius)
	local IgnoreObjects = {(((Creator and Creator.Parent and Creator.Character and Creator.Character.Parent) and Creator.Character) or nil)}
	local NegativePartRadius = Vector3.new(Radius, Radius, Radius)
	local PositivePartRadius = Vector3.new(Radius, (Pumpkin.Size.Y / 2), Radius)
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Pumpkin.CFrame.p - NegativePartRadius, Pumpkin.CFrame.p + PositivePartRadius), IgnoreObjects, 100)
	local Humanoids = {}
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local character = v.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
				local ForceFieldExists = false
				for i, v in pairs(character:GetChildren()) do
					if v:IsA("ForceField") then
						ForceFieldExists = true
					end
				end
				if not ForceFieldExists then
					table.insert(Humanoids, humanoid)
				end
			end
		end
	end
	return Humanoids
end

function Blackout()
	local HumanoidsNearby = GetPlayersNearby(MaxRadius)
	for i, v in pairs(HumanoidsNearby) do
		if v:IsA("Humanoid") and v.Parent then
			local player = Players:GetPlayerFromCharacter(v.Parent)
			if player then
				local PlayerBlackoutScript = game:GetService("Workspace"):FindFirstChild(player.Name .. BlackoutScript.Name)
				if player and not PlayerBlackoutScript and not v:FindFirstChild("ClientScript") then
					local BlackoutScriptClone = BlackoutScript:Clone()
					BlackoutScriptClone.Name = (player.Name .. BlackoutScript.Name)
					local Creator = Instance.new("ObjectValue")
					Creator.Name = "Creator"
					Creator.Value = player
					Creator.Parent = BlackoutScriptClone
					BlackoutScriptClone.Disabled = false
					local UnconsciousDuration = Instance.new("NumberValue")
					UnconsciousDuration.Name = "UnconsciousDuration"
					UnconsciousDuration.Value = 2
					UnconsciousDuration.Parent = BlackoutScriptClone
					BlackoutScriptClone.Parent = game:GetService("Workspace")
				elseif PlayerBlackoutScript then
					local UnconsciousDuration = PlayerBlackoutScript:FindFirstChild("UnconsciousDuration")
					if UnconsciousDuration then
						UnconsciousDuration.Value = 2
					end
				end
			end
		end
	end
end

if Creator and Creator.Parent and Creator:IsA("Player") then
	Creator.Changed:connect(function(Property)
		if Property == "Character" and not Creator.Character.Parent then
			Pumpkin:Destroy()
		end
	end)
end

Spawn(function()
	while true do
		EmitStink()
		Blackout()
		wait(0.01)
	end
end)