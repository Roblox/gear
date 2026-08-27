--Made by Luckymaxer

Firework = script.Parent

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

ImageFirework = require(script:WaitForChild("ImageFirework"))

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

Colors = {
	Color3.new((255 / 255), (0 / 255), (0 / 255)),
	Color3.new((255 / 255), (255 / 255), (255 / 255)),
	Color3.new((0 / 255), (0 / 255), (255 / 255)),
	Color3.new((0 / 255), (0 / 255), (0 / 255)),
	Color3.new((230 / 255), (230 / 255), (230 / 255)),
	Color3.new((0 / 255), (100 / 255), (255 / 255)),
	Color3.new((0 / 255), (255 / 255), (75 / 255)),
}

Gravity = workspace.Gravity

BodyVelocity = Firework:WaitForChild("BodyVelocity")

Sounds = {
	Fly = Firework:WaitForChild("Fly"),
	Explode = Firework:WaitForChild("Explode"),
	Bang = Firework:WaitForChild("Bang"),
	Pop = Firework:WaitForChild("Pop"),
}

Particles = {}

for i, v in pairs(Firework:GetChildren()) do
	if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Light") then
		table.insert(Particles, v)
		if v.Name == "Fire" then
			v.Enabled = true
		end
	end
end

function TransformModel(Objects, Center, NewCFrame, Recurse)
	Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function DisplayImageFirework(Location) --2018 image firework made by masterbeyblade21
	local Firework = ImageFirework:Clone()
	Debris:AddItem(Firework, 10)
	TransformModel(Firework, Firework:GetModelCFrame(), Location, true)
	local ImageColors = {
		Color3.new((0 / 255), (85 / 255), (255 / 255)),
		Color3.new((255 / 255), (0 / 255), (25 / 255)),
		Color3.new((255 / 255), (255 / 255), (255 / 255)),
	}
	local SelectedColor = ImageColors[math.random(1, #ImageColors)]
	for i, v in pairs(Firework:GetChildren()) do
		if v:IsA("BasePart") then
			local Offset = v.Position
			v.CFrame = Location
			local Mass = (v:GetMass() * Gravity * 100)
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyPosition.position = Offset
			BodyPosition.Parent = v
			v.Anchored = false
			v.CanCollide = false
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("Smoke") then
					vv.Color = SelectedColor
				elseif vv:IsA("Sparkles") then
					vv.SparkleColor = SelectedColor
				elseif vv:IsA("Fire") then
					vv.Color = SelectedColor
					vv.SecondaryColor = SelectedColor
				elseif vv:IsA("ParticleEmitter") then
					vv.Color = ColorSequence.new(SelectedColor, SelectedColor)
				end
			end
		end
	end
	Firework.Parent = game:GetService("Workspace")
	wait(8)
	for i, v in pairs(Firework:GetChildren()) do
		if v:IsA("BasePart") then
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("Sparkles") or vv:IsA("Fire") or vv:IsA("Smoke") or vv:IsA("ParticleEmitter") then
					vv.Enabled = false
				end
			end
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
	Part.Transparency = 1
	Part.Size = Vector3.new(0.2, 0.2 ,0.2)
	Part.CanCollide = false
	Part.CFrame = (Table.Position * CFrame.Angles(0, 0, 0))
	Part.Velocity = Table.Velocity

	for i = 1, 4 do
		local Sparkles = Create("Sparkles"){
			SparkleColor = ((i % 2 == 0 and Color3.new((144 / 255), (25 / 255), (255  /255)) or Color3.new((255 / 255), (255 / 255), 0))),
			Enabled = true,
		}
		table.insert(Particles, Sparkles)
		Sparkles.Parent = Part
	end
	
	local Fire = Create("Fire"){
		Color = Color3.new((255 / 255), (255 / 255), (127 / 255)),
		SecondaryColor = Color3.new((255 / 255), (255 / 255), (255 / 255)),
		Heat = 25,
		Size = (Extra.FireSize or 5),
		Enabled = true,
	}
	
	local Light = Create("PointLight"){
		Color = Fire.Color,
		Range = 10,
		Brightness = 100,
		Enabled = true,
	}
	
	for i, v in pairs({Fire, Light}) do
		table.insert(Particles, v)
		v.Parent = Part
	end
	
	for i, v in pairs(Particles) do
		if v:IsA("Sparkles") then
			v.SparkleColor = (Table.Color or v.SparkleColor)
		else
			v.Color = (Table.Color or v.Color)
		end
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
		for i, v in pairs(Particles) do
			v.Enabled = false
		end
	end)

	return Part
end

function Explode()
	local ExplosionType = math.random(1, 4)
	if ExplosionType == 1 then
		local FlareAmount = 24
		local FlareTime = 3
		local FlareRate = (FlareTime / FlareAmount)
		local Color =  Color3.new((255 / 255), (255 / 255), (127 / 255))
		for i = 1, FlareAmount do
			wait(FlareRate)
			Sounds.Pop:Play()
			Flare({
				Position = Firework.CFrame,
				Velocity = ((Firework.CFrame * CFrame.Angles(0, (((i % 9) / 9) * math.pi * 2), 0)).lookVector * 20 + Firework.Velocity),
				Float = 0.8,
				Time = 2,
				Color = Color,
				Extra = {},
			})
		end
	elseif ExplosionType == 2 then
		Sounds.Bang:Play()
		local Explosions = {
			{Sparks = 14, Velocity = 35, Float = 1.1, Time = 1},
			{Sparks = 14, Velocity = 30, Float = 1, Time = 1},
		}
		for i, v in pairs(Explosions) do
			local Color = Colors[math.random(1, #Colors)]
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
	elseif ExplosionType == 3 then
		Sounds.Explode:Play()
		local Explosions = {
			{Sparks = 20, Velocity = 65, Float = 1.5, Time = 1.2},
			{Sparks = 20, Velocity = 60, Float = 1.25, Time = 1.2},
		}
		for i, v in pairs(Explosions) do
			local Color = Colors[math.random(1, #Colors)]
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
	elseif ExplosionType == 4 then
		local Explosions = {
			{Position = (Firework.CFrame * CFrame.new(-15, 0, 0)), Sparks = 14, Velocity = 10, Float = 0.95, Time = 1.25},
			{Position = (Firework.CFrame * CFrame.new(15, 0, 0)), Sparks = 14, Velocity = 10, Float = 0.95, Time = 1.25},
			{Position = (Firework.CFrame * CFrame.new(-45, 0, 0)), Sparks = 14, Velocity = 10, Float = 0.95, Time = 1.25},
			{Position = (Firework.CFrame * CFrame.new(45, 0, 0)), Sparks = 14, Velocity = 10, Float = 0.95, Time = 1.25},
		}
		Sounds.Bang:Play()
		for i, v in pairs(Explosions) do
			local Color = Colors[math.random(1, #Colors)]
			local FireworkCFrame = Firework.CFrame * CFrame.Angles(math.pi, (math.random(-360, 360) * 0.01), (math.pi / 2))
			for ii = 1, v.Sparks do
				local Part = Flare({
					Position = (v.Position or Firework.Position),
					Velocity = ((FireworkCFrame * CFrame.Angles(((ii / v.Sparks) * math.pi * 2), 0, 0)).lookVector * v.Velocity),
					Float = v.Float,
					Timer = v.Time,
					Color = Color,
					Extra = {},
				})
			end
		end
	end
end

Sounds.Fly:Play()

Delay(1.25, (function()
	for i, v in pairs(Particles) do
		v.Enabled = false
	end
end))

wait(3)

for i, v in pairs(Particles) do
	v.Enabled = false
end

Firework.Anchored = true
Firework.CanCollide = false
Firework.Transparency = 1
Debris:AddItem(BodyVelocity, 0)

Explode()
DisplayImageFirework(((Firework.CFrame + Vector3.new(0, 25, 0)) * CFrame.Angles((math.pi / 2), 0, 0)))

--Sounds.Explode:Play()

wait(3)

Sounds.Explode:Stop()

Firework:Destroy()
