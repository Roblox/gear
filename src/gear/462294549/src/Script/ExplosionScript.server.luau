--Made by Luckymaxer

Firework = script.Parent

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

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

Gravity = 196.20

BodyVelocity = Firework:WaitForChild("BodyVelocity")

Sounds = {
	Fly = Firework:WaitForChild("Fly"),
	Explode = Firework:WaitForChild("Explode"),
	Bang = Firework:WaitForChild("Bang"),
	Pop = Firework:WaitForChild("Pop"),
}

Particles = {}

Colors = {
	Color3.new(255, 0, 0),
	Color3.new(0, 255, 0),
	Color3.new(0, 0, 255),
	Color3.new(255, 170, 0),
	Color3.new(255, 255, 0),
	Color3.new(0, 255, 255),
	Color3.new(255, 0, 255),
	Color3.new(85, 0, 0),
	Color3.new(170, 0, 255),
}

for i, v in pairs(Firework:GetChildren()) do
	if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Light") then
		table.insert(Particles, v)
		if v.Name == "Fire" then
			v.Enabled = true
		end
	end
end

function Flare(Table)
	local Float = (Table.Float or 0)
	local Timer = (Table.Timer or 2)
	local Extra = (Table.Extra or {})
	
	local Particles = {}
	
	local Part = BasePart:Clone()
	Part.Name = "EffectFlare"
	Part.Transparency = 0
	Part.BrickColor = BrickColor.new(Table.Color)
	Part.Material = Enum.Material.Neon
	Part.Size = Vector3.new(0.5, 0.5, 0.5)
	Part.CanCollide = false
	Part.CFrame = (Table.Position * CFrame.Angles(0, 0, 0))
	Part.Velocity = Table.Velocity
	
	local Light = Create("PointLight"){
		Color = Color3.new((255 / 255), (255 / 255), (127 / 255)),
		Range = 10,
		Brightness = 100,
		Enabled = true,
	}
	
	for i, v in pairs({Light}) do
		table.insert(Particles, v)
		v.Parent = Part
	end
	
	for i, v in pairs(Particles) do
		v.Color = (Table.Color or v.Color)
	end
	
	if Float > 0 then
		local BodyForce = Create("BodyForce"){
			force = Vector3.new(0, (Part:GetMass() * Gravity * Float), 0),
			Parent = Part,
		}
	end
	
	Debris:AddItem(Part,(Timer + 3))
	Part.Parent = game:GetService("Workspace")
	Delay(Timer, function()
		Part.Transparency = 1
		for i, v in pairs(Particles) do
			v.Enabled = false
		end
	end)

	return Part
end

function Explode()
	local ExplosionType = math.random(1, 4)
	Sounds.Bang:Play()
	local Explosions = {
		{Sparks = 14, Velocity = 25, Float = 1.05, Time = 1.25},
		{Sparks = 14, Velocity = 20, Float = 1, Time = 1.25},
	}
	for i, v in pairs(Explosions) do
		local Color = Colors[math.random(1, #Colors)]
		Color = Color3.new((Color.r / 255), (Color.g / 255), (Color.b / 255))
		local FireworkCFrame = Firework.CFrame * CFrame.Angles(math.pi, (math.random(-360, 360) * 0.01), (math.pi / 2))
		for ii = 1, v.Sparks do
			local Part = Flare({
				Position = Firework.CFrame,
				Velocity = ((FireworkCFrame * CFrame.Angles(((ii / v.Sparks) * math.pi * 2), 0, 0)).lookVector * v.Velocity),
				Float = v.Float,
				Timer = v.Time,
				Color = Color,
				Extra = {FireSize = 10},
			})
		end
	end
end

Sounds.Fly:Play()

Delay(1.25, (function()
	for i, v in pairs(Particles) do
		v.Enabled = false
	end
end))

wait(1.85)

for i, v in pairs(Particles) do
	v.Enabled = false
end

Firework.Anchored = true
Firework.CanCollide = false
Firework.Transparency = 1
Debris:AddItem(BodyVelocity, 0)

Explode()

--Sounds.Explode:Play()

wait(3)

Sounds.Explode:Stop()

Firework:Destroy()
