--Made by Luckymaxer

Figure = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Figure:FindFirstChild("Creator")

Humanoid = Figure:FindFirstChild("Humanoid")
Head = Figure:FindFirstChild("Head")
Torso = Figure:FindFirstChild("Torso")

HealthDisplay = script:WaitForChild("HealthDisplay")

Gravity = 196.20

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true

function Destroy()
	Debris:AddItem(Figure, 2)
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

if not Creator or not Creator.Value or not Creator.Value.Parent or not Humanoid or Humanoid.Health == 0 or not Head or not Torso then
	Destroy()
	return
end

Player = Creator.Value
Character = Player.Character

BodyGyro = Torso:FindFirstChild("BodyGyro")
BodyPosition = Torso:FindFirstChild("BodyPosition")

if not Player or not Character or not BodyGyro or not BodyPosition then
	Destroy()
	return
end

PlayerHumanoid = Character:FindFirstChild("Humanoid")
PlayerTorso = Character:FindFirstChild("Torso")

if not PlayerHumanoid or PlayerHumanoid.Health == 0 or not PlayerTorso then
	Destroy()
	return
end

Player.Changed:connect(function(Property)
	if not Player.Parent then
		Destroy()
	end
end)

Character.Changed:connect(function(Property)
	if not Character.Parent then
		Destroy()
	end
end)

Humanoid.Changed:connect(function(Property)
	DamageFrame.Size = UDim2.new((1 / (Humanoid.MaxHealth / Humanoid.Health)), 0, 1, 0)
	if not Humanoid.Parent or Humanoid.Health == 0 then
		Destroy()
	end
end)

PlayerHumanoid.Changed:connect(function(Property)
	if not PlayerHumanoid.Parent or PlayerHumanoid.Health == 0 then
		Destroy()
	end
end)

HealthDisplay.Adornee = Head
HealthDisplay.Enabled = true

DamageFrame = HealthDisplay.Frame.Frame

DamageFrame.Size = UDim2.new((1 / (Humanoid.MaxHealth / Humanoid.Health)), 0, 1, 0)

Spawn(function()
	local HealTick = 0
	local SelfHealTick = 0
	local Mass = ((GetTotalMass(Figure) * Gravity) * 100)
	BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
	while BodyGyro.Parent and BodyPosition.Parent and Humanoid.Health > 0 do
		BodyGyro.cframe = PlayerTorso.CFrame
		local Position = (PlayerTorso.CFrame + PlayerTorso.CFrame.lookVector * -(PlayerTorso.Size.Z * 1.5))
		Position = (Position + (Position * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Torso.Size.X * 2)).p
		BodyPosition.position = Position
		if (tick() - SelfHealTick) >= 1 then
			Humanoid.Health = (Humanoid.Health + 5)
			SelfHealTick = tick()
		end
		if PlayerHumanoid.Health < PlayerHumanoid.MaxHealth and (tick() - HealTick) >= 2 then
			local HealSphere = BasePart:Clone()
			HealSphere.Name = "HealSphere"
			HealSphere.BrickColor = BrickColor.new("Teal")
			HealSphere.Transparency = 0.5
			HealSphere.Size = Vector3.new(0.75, 0.75, 0.75)
			HealSphere.CanCollide = false
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.Sphere
			Mesh.Parent = HealSphere
			Mesh.Scale = Vector3.new(1, 1, 1)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.Parent = HealSphere
			Debris:AddItem(HealSphere, 2)
			HealSphere.Parent = game:GetService("Workspace")
			HealSphere.CFrame = Torso.CFrame
			HealSphere.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				if Hit.Parent == Character then
					PlayerHumanoid.Health = (PlayerHumanoid.Health + 5)
					HealSphere:Destroy()
				end
			end)
			Spawn(function()
				while HealSphere and HealSphere.Parent and BodyVelocity and BodyVelocity.Parent do
					BodyVelocity.velocity = CFrame.new(HealSphere.Position, PlayerTorso.Position).lookVector * 20
					HealSphere.Velocity = BodyVelocity.velocity
					wait(0.1)
				end
			end)
			HealTick = tick()
			if PlayerHumanoid.Health == PlayerHumanoid.MaxHealth then
				HealTick = 0
			end
		end
		wait(0.1)
	end
end)