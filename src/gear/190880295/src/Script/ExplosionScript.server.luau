--Made by Luckymaxer

Firework = script.Parent

Debris = game:GetService("Debris")

Sounds = {
	Fly = Firework:WaitForChild("Fly"),
	Explode = Firework:WaitForChild("Explode")
}

Duration = script:FindFirstChild("Duration")

BodyForce = Firework:FindFirstChild("BodyForce")

Colors = {
	Color3.new((255 / 255), 0, 0),
	Color3.new(0, 0, (255 / 255)),
	Color3.new((255 / 255), (255 / 255), (255 / 255)),
	Color3.new((0 / 255), (0 / 255), (0 / 255)),
	Color3.new((255 / 255), (122 / 255), (0 / 255))
}

Gravity = 196.20

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

function Flare(Position, Velocity, Float, Timer, Color)
	local Float = (Float or 0)
	local Timer = (Timer or 2)
	
	local Part = BasePart:Clone()
	Part.Name = "EffectFlare"
	Part.Transparency = 1
	Part.Size = Vector3.new(0.4, 0.4, 0.4)
	Part.CanCollide = false
	Part.CFrame = CFrame.new(Position) * CFrame.Angles(0, 0, 0)
	Part.Velocity = Velocity
	
	local Particles = {
		Sparkles = {},
		Fire = {}
	}

	for i = 1, 4 do
		local Sparkles = Instance.new("Sparkles")
		Sparkles.SparkleColor = BrickColor.new(((i % 2 == 0 and "Institutional white") or "New Yeller")).Color
		Sparkles.Enabled = true
		table.insert(Particles.Sparkles, Sparkles)
		Sparkles.Parent = Part
	end
	
	local Fire = Instance.new("Fire")
	Fire.Color = BrickColor.new("Tr. Flu. Yellow").Color
	Fire.SecondaryColor = BrickColor.new("Institutional white").Color
	Fire.Heat = 25
	Fire.Size = 5
	Fire.Enabled = true
	table.insert(Particles.Fire, Fire)
	Fire.Parent = Part
		
	for i, v in pairs(Particles.Sparkles) do
		if v and v.Parent then
			v.SparkleColor = Color
		end
	end
	
	for i, v in pairs(Particles.Fire) do
		if v and v.Parent then
			v.Color = BrickColor.new(Color).Color
		end
	end
	
	if Float > 0 then
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, (Part:GetMass() * Gravity * Float), 0)
		BodyForce.Parent = Part
	end
	
	Debris:AddItem(Part,(Timer + 3))
	Part.Parent = game:GetService("Workspace")
	Delay(Timer, function()
		for i, v in pairs(Particles) do
			if v and v.Parent and v.Enabled then
				v.Enabled = false
			end
		end
	end)

	return Part
end

Sounds.Fly:Play()

if Duration and Duration.Value > 0 then
	wait(Duration.Value)
end

wait(1)

Sounds.Explode:Play()

Firework.Anchored = true
Firework.CanCollide = false
Firework.Transparency = 1

if BodyForce and BodyForce.Parent then
	BodyForce:Destroy()
end

local ColorChosen = Colors[math.random(1, #Colors)]
local FireworkPosition = Firework.CFrame * CFrame.Angles(math.pi, math.random(-360, 360), (math.pi / 2))

local Parts = {}
for i = 1, 14 do
	local Part = Flare(Firework.Position, ((FireworkPosition * CFrame.Angles(((i / 7) * math.pi * 2), 0, 0)).lookVector * 50), 0.95, 2.9, ColorChosen)
	local Explosion = Sounds.Explode:Clone()
	Explosion.Parent = Part
	table.insert(Parts, {Part = Part, Explosion = Explosion})
end

wait(3)

for i = 1, #Parts do
	local PartIndex = math.random(1, #Parts)
	local v = Parts[PartIndex]
	table.remove(Parts, PartIndex)
	if v.Part and v.Part.Parent then
		local FireworkPosition = v.Part.CFrame * CFrame.Angles(math.pi, math.random(-360, 360), (math.pi / 2))
		ColorChosen = Colors[math.random(1, #Colors)]
		for ii = 1, 7 do
			Flare(v.Part.Position, ((FireworkPosition * CFrame.Angles(((ii / 7) * math.pi * 2), 0.25, 0)).lookVector * 20), 0.95, 3, ColorChosen)
		end
		v.Explosion:Play()
	end
	wait(0.25)
end

wait(2)

Sounds.Explode:Stop()

Firework:Destroy()