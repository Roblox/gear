--Made by Luckymaxer

Table = script.Parent
Creator = Table:FindFirstChild("Creator")
Player = Creator.Value
Character = Player.Character

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

ExplosionSound = Instance.new("Sound")
ExplosionSound.Name = "ExplosionSound"
ExplosionSound.SoundId = "http://www.roblox.com/asset?id=110284742"
ExplosionSound.Volume = 2
ExplosionSound.Pitch = 2
ExplosionSound.Looped = false
ExplosionSound.Parent = Table

Explosion = Instance.new("Part")
Explosion.Name = "Explosion"
Explosion.Anchored = true
Explosion.CanCollide = false
Explosion.Locked = true
Explosion.Material = Enum.Material.Plastic
Explosion.Shape = Enum.PartType.Block
Explosion.TopSurface = Enum.SurfaceType.Smooth
Explosion.BottomSurface = Enum.SurfaceType.Smooth
Explosion.FormFactor = Enum.FormFactor.Custom
Explosion.Size = Vector3.new(1, 1, 1)
ExplosionMesh = Instance.new("SpecialMesh")
ExplosionMesh.MeshType = Enum.MeshType.FileMesh
ExplosionMesh.MeshId = "http://www.roblox.com/asset?id=153994027"
ExplosionMesh.TextureId = "http://www.roblox.com/asset?id=153994115"
ExplosionMesh.Scale = Vector3.new(0.15, 0.15, 0.15)
ExplosionMesh.Parent = Explosion

wait(10)

Explosion.Parent = game:GetService("Workspace")
Explosion.CFrame = CFrame.new(Table.Position) + Vector3.new(0, ((Explosion.Size.Y / 2) - (Table.Size.Y / 2)), 0)

OriginalCFrame = Explosion.CFrame

ExplosionSound:Play()

Table.Transparency = 1
Table.Anchored = true
Table.CanCollide = false

Explosion.Touched:connect(function(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and humanoid and humanoid.Health > 0 and character ~= Character then
			local torso = character:FindFirstChild("Torso")
			if torso then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(5)
				humanoid.Sit = true
				torso.Velocity = torso.Velocity + CFrame.new(Explosion.Position, torso.Position).lookVector * 10
			end
		end
	end
end)

for i = 1, 100, 0.5 do
	Explosion.Size = Explosion.Size + Vector3.new(0.5, 0.5, 0.5)
	ExplosionMesh.Scale = ExplosionMesh.Scale + Vector3.new(0.075, 0.075, 0.075)
	Explosion.CFrame = OriginalCFrame + Vector3.new(0, ((i * 0.5) / 1), 0)
	wait()
end

Explosion:Destroy()

SmokeCloud = Instance.new("Smoke")
SmokeCloud.Color = Color3.new(0.45098, 0.45098, 0.45098)
SmokeCloud.Opacity = 1
SmokeCloud.RiseVelocity = 10
SmokeCloud.Size = 10
SmokeCloud.Parent = Table

wait(10)

Table:Destroy()