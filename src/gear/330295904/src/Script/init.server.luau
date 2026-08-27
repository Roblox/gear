--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Sparkles = script:WaitForChild("Sparkles")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 5

Colors = {"Really red", "Lime green"}

Projectile = Instance.new("Part")
Projectile.Name = "Projectile"
Projectile.Transparency = 0.25
Projectile.Material = Enum.Material.Neon
Projectile.Shape = Enum.PartType.Block
Projectile.TopSurface = Enum.SurfaceType.Smooth
Projectile.BottomSurface = Enum.SurfaceType.Smooth
Projectile.FormFactor = Enum.FormFactor.Custom
Projectile.Size = Vector3.new(0.2, 2, 0.2)
Projectile.Anchored = false
Projectile.Locked = true
Projectile.CanCollide = false
Mesh = Instance.new("BlockMesh")
Mesh.Name = "Mesh"
Mesh.Scale = Vector3.new(0.5, 1, 0.5)
Mesh.VertexColor = Vector3.new(1, 1, 1)
Mesh.Offset = Vector3.new(0, 0, 0)
Mesh.Parent = Projectile
PointLight = Instance.new("PointLight")
PointLight.Name = "Light"
PointLight.Brightness = 50
PointLight.Range = 3
PointLight.Shadows = false
PointLight.Enabled = true
PointLight.Parent = Projectile

FireFunction = (Tool:FindFirstChild("FireFunction") or Instance.new("RemoteFunction"))
FireFunction.Name = "FireFunction"
FireFunction.Parent = Tool

FireFunction.OnServerInvoke = (function(Player, Origin, Direction)
	local Character = Player.Character
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid then
		return
	end
	local Color = BrickColor.new(Colors[math.random(1, #Colors)])
	local ProjectileClone = Projectile:Clone()
	ProjectileClone.BrickColor = Color
	ProjectileClone.Light.Color = Color.Color
	local SparklesCopy = Sparkles:Clone()
	SparklesCopy.Color = ColorSequence.new(Color.Color, Color.Color)
	SparklesCopy.Enabled = true
	SparklesCopy.Parent = ProjectileClone
	local Mass = (ProjectileClone:GetMass() * 196.20)
	local BodyForce = Instance.new("BodyForce")
	BodyForce.force = Vector3.new(0, Mass, 0)
	BodyForce.Parent = ProjectileClone
	ProjectileClone.Touched:connect(function(Hit)
		if Hit and Hit.Parent and Hit ~= Handle then
			if Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool") then
				Hit = Hit.Parent
			end
			local humanoid = Hit.Parent:FindFirstChild("Humanoid")
			if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			end
			if ProjectileClone and ProjectileClone.Parent then
				ProjectileClone:Destroy()
			end
		end
	end)
	Debris:AddItem(ProjectileClone, 3)
	ProjectileClone.Parent = game:GetService("Workspace")
	ProjectileClone.CFrame = Origin
	Direction = CFrame.new(ProjectileClone.Position, Direction)
	ProjectileClone.CFrame = Direction * CFrame.Angles((math.pi / 2), 0, 0)
	ProjectileClone.Velocity = Direction.lookVector * 125
end)

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