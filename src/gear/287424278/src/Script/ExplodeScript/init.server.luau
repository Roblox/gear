--Made by Luckymaxer

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Figure:WaitForChild("Creator")

Functions = require(script:WaitForChild("Functions"))

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Sounds = {
	Explosion = script:WaitForChild("Explosion")
}

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

function GetNearbyObjects(Region)
	local IgnoreList = {Figure}
	if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character then
		table.insert(IgnoreList, Creator.Value.Character)
	end
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Creator.Value and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 2000, IgnoreList)
end

function Explode()
	local Origin = Torso.Position
	local Radius = 15
	local Damage = 100
	Spawn(function()
		local Explosion = BasePart:Clone()
		Explosion.Name = "Effect"
		Explosion.BrickColor = BrickColor.new("Toothpaste")
		Explosion.Anchored = true
		Explosion.CanCollide = false
		local Sound = Sounds.Explosion:Clone()
		Sound.Parent = Explosion
		local Mesh = Create("SpecialMesh"){
			Name = "Mesh",
			MeshType = Enum.MeshType.Sphere,
			Scale = (Vector3.new(1, 1, 1) * Radius * 5 * 2),
			VertexColor = Vector3.new(1, 1, 1),
			Offset = Vector3.new(0, 0, 0),
			Parent = Explosion,
		}
		Spawn(function()
			local Region = Region3.new((Origin - Vector3.new(Radius, Radius, Radius)), (Origin + Vector3.new(Radius, Radius, Radius)))
			local Objects = GetNearbyObjects(Region)
			local HumanoidsHit = {}
			for i, v in pairs(Objects) do
				local character = v.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 and not Functions.CheckTableForInstance(HumanoidsHit, humanoid) then
					table.insert(HumanoidsHit, humanoid)
					local creator = character:FindFirstChild("Creator")
					if (not creator or (creator and creator.Value ~= Creator.Value)) then
						Functions.UntagHumanoid(humanoid)
						Functions.TagHumanoid(humanoid, Creator.Value)
						humanoid:TakeDamage(Damage)
					end
				end
			end
		end)
		local Rate = 0.033
		local Frames = math.floor(0.5 / Rate)
		Debris:AddItem(Explosion, ((Frames * Rate) + 1))
		Explosion.CFrame = CFrame.new(Origin)
		Explosion.Parent = game:GetService("Workspace")
		Sound:Play()
		Spawn(function()
			for Frame = 1, Frames do
				local Percent = (Frame / Frames)
				Mesh.Scale = ((Vector3.new(1, 1, 1) * Radius * 5 * 2) * (1 - Percent))
				Explosion.Transparency = (1 - Percent)
				wait(Rate)
			end
			if Explosion and Explosion.Parent then
				Explosion:Destroy()
			end
		end)
	end)
end

function Died()
	Explode()
end

Humanoid.Died:connect(Died)