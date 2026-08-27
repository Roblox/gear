--Made by Luckymaxer

Model = script.Parent
Center = Model:WaitForChild("Center")
Pumpkin = Model:WaitForChild("Pumpkin")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FireworksModule = require(182191976)
ImageFireworks = FireworksModule.Fireworks

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

Gravity = 196.20

Fireworks = {}

Sounds = {
	-- Explosion
	Explosion1 = 181686249,
	Explosion2 = 181686389,
	Explosion3 = 181686408,
	Explosion4 = 181686431,
	ExplosionWithCrackle = 181686460,
	DistantExplosion1 = 181685954,
	DistantExplosion2 = 181686071,
	DistantExplosion3 = 181686095,
	SoftExplosion = 181686722,
	-- Whistle
	Whistle1 = 181686553,
	Whistle2 = 181686590,
	Whistle3 = 181686621,
	WhistleWithExplosion = 181686868,
	ModerateWhistle = 181686679,
	FastWhistle = 181686197,
	--Launch
	Launch = 181686490,
	FastLaunch = 181686124,	
}

FireworkDud = false

for i, v in pairs(Model:GetChildren()) do
	if v:IsA("BasePart") and v ~= Center and v ~= Pumpkin then
		table.insert(Fireworks, v)
	end
end

function PlaySound(Object, SoundId, Pitch, Volume, Duration)
	if not Object then
		return
	end
	local Sound = Instance.new("Sound")
	Sound.SoundId = (((type(SoundId) == "number" and "http://www.roblox.com/asset?id=") or "") .. SoundId)
	Sound.Pitch = (Pitch or Sound.Pitch)
	Sound.Volume = (Volume or Sound.Volume)
	Sound.Parent = Object
	Sound:Play()
	Delay(Duration, function()
		Sound:Stop()
	end)
	return Sound
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function IsFlipped(Object)
	local Vector1 = Object.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > 0.5)
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

function ClassicExplosion(Firework)
	if not Firework or not Firework.Parent then
		return
	end
	local Colors = {"Really red", "Really blue", "New Yeller", "Lime green", "Bright violet"}
	local function Flare(Position, Velocity, Float, Timer, Color)
		local Float = (Float or 0)
		local Timer = (Timer or 2)
		
		local Part = BasePart:Clone()
		Part.Name = "EffectFlare"
		Part.Transparency = 1
		Part.Size = Vector3.new(0.4, 0.4, 0.4)
		Part.CanCollide = false
		Part.CFrame = CFrame.new(Position) * CFrame.Angles(math.pi, 0, 0)
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
				v.SparkleColor = BrickColor.new(((i % 2 == 0 and v.SparkleColor) or Color)).Color
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
	local ColorChosen = Colors[math.random(1, #Colors)]
	local FireworkPosition = Firework.CFrame * CFrame.Angles((math.random() * math.pi * 2), (math.random() * math.pi * 2), (math.random() * math.pi * 2))
	if Firework and Firework.Parent then
		Firework:Destroy()
	end
	for i = 1, 7 do
		Flare(Firework.Position, ((FireworkPosition * CFrame.Angles(((i / 7) * math.pi * 2), 0.75, 0)).lookVector * 20), 0.95, 2, ColorChosen)
	end
	for i = 1, 7 do
		Flare(Firework.Position, ((FireworkPosition * CFrame.Angles(((i / 7) * math.pi * 2), -0.75, 0)).lookVector * 20), 0.95, 2, ColorChosen)
	end
end

function ImageExplosion(Firework)
	if not FireworksUsable then
		FireworksUsable = {}
		for i, v in pairs(ImageFireworks) do
			table.insert(FireworksUsable, v)
		end
	end
	local function ChooseFirework()
		if #FireworksUsable > 0 then
			local FireworkChosenNumber = math.random(1, #FireworksUsable)
			local FireworkChosen = FireworksUsable[FireworkChosenNumber]
			table.remove(FireworksUsable, FireworkChosenNumber)
			return FireworkChosen
		else
			 HandleFirework(ClassicExplosion, Firework)
			return
		end
	end
	if not Firework or not Firework.Parent then
		return
	end
	local FireworkChosen = ChooseFirework()
	if not FireworkChosen then
		return
	end
	local FireworkPosition = Firework.CFrame
	if Firework and Firework.Parent then
		Firework:Destroy()
	end
	local Firework = FireworkChosen.Firework:Clone()
	local Parts = {}
	local Particles = {}
	for i, v in pairs(Firework:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("Fire") or vv:IsA("Smoke") or vv:IsA("Sparkles") or vv:IsA("PointLight") or vv:IsA("SpotLight") then
					table.insert(Particles, vv)
					vv.Enabled = false
				end
			end
		end
	end
	local Duration = 8
	Debris:AddItem(Firework, Duration)
	Firework.Parent = game:GetService("Workspace")
	Delay((Duration - 3), function()
		for i, v in pairs(Particles) do
			if v and v.Parent then
				v.Enabled = false
			end
		end
	end)
	TransformModel(Firework, Firework:GetModelCFrame(), FireworkPosition, true)
	TransformModel(Firework, Firework:GetModelCFrame(), CFrame.new(Firework:GetModelCFrame().p, Center.Position), true)
	if FireworkChosen.Angle then
		TransformModel(Firework, Firework:GetModelCFrame(), Firework:GetModelCFrame() * FireworkChosen.Angle)
	end
	local OriginalPositions = {}
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local Offset = v.Position
			v.CFrame = FireworkPosition
			local Mass = (v:GetMass() * Gravity * 100)
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyPosition.position = Offset
			BodyPosition.Parent = v
			v.Anchored = false
		end
	end
	for i, v in pairs(Particles) do
		if v and v.Parent then
			v.Enabled = true
		end
	end
end

function HandleFirework(FireworkFunction, Firework)
	pcall(function()
		if not Firework or not Firework.Parent then
			return
		end
		local ExplosionSounds = {Sounds.Explosion2, Sounds.Explosion3, Sounds.Explosion4}
		PlaySound(Firework, ExplosionSounds[math.random(1, #ExplosionSounds)], nil, 3, 2)
		--local ExplosionSounds = {Sounds.DistantExplosion1, Sounds.DistantExplosion2, Sounds.DistantExplosion3}
		--PlaySound(Firework, ExplosionSounds[math.random(1, #ExplosionSounds)], nil, 3, 3)
		Spawn(function()
			FireworkFunction(Firework)
		end)
	end)
end

Fire = Instance.new("Fire")
Fire.Color = BrickColor.new("Deep orange").Color
Fire.SecondaryColor = BrickColor.new("Really red").Color
Fire.Heat = 25
Fire.Size = 2.125
Fire.Enabled = true
Fire.Parent = Pumpkin

wait(2)

if IsFlipped(Center) then
	FireworkDud = true
end

Center.CanCollide = false

local ExplosionType = math.random(1, 3)

for i, v in pairs(Fireworks) do
	Spawn(function()
		local LaunchSounds = {Sounds.Launch, Sounds.FastLaunch}
		PlaySound(Center, LaunchSounds[math.random(1, #LaunchSounds)], nil, nil, 3)
		local IndividualDud = ((IsFlipped(Center) and true) or false)
		local Firework = v:Clone()
		local WhistleSounds = {Sounds.Whistle1, Sounds.Whistle2, Sounds.Whistle3, Sounds.ModerateWhistle, Sounds.FastWhistle}
		PlaySound(Firework, WhistleSounds[math.random(1, #WhistleSounds)], nil, nil, 3)
		v.CanCollide = false
		v.Transparency = 1
		Firework.CanCollide = true
		Firework.Transparency = 0
		local FireworkOrigin = Firework.CFrame + (Firework.CFrame * CFrame.Angles((math.pi / 2), 0, 0)).lookVector * Firework.Size.Y
		local FireworkCFrame = Firework.CFrame + CFrame.new(Pumpkin.Position, FireworkOrigin.p).lookVector * 1.5
		local Mass = (Firework:GetMass() * Gravity * 2)
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.cframe = Firework.CFrame
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
		if not FireworkDud and not IndividualDud then
			BodyGyro.Parent = Firework
			BodyVelocity.Parent = Firework
		end
		Debris:AddItem(Firework, 10)
		Firework.CFrame = FireworkCFrame
		BodyVelocity.velocity = CFrame.new(Pumpkin.Position, FireworkOrigin.p).lookVector * 100
		Firework.Parent = game:GetService("Workspace")
		if v and v.Parent then
			v:Destroy()
		end
		if not FireworkDud then
			wait((math.random(30, 50) * 0.1))
			local DistanceApart = (Firework.Position.Y - Center.Position.Y)
			local RayHit, RayPos = RayCast(Firework.Position, Vector3.new(0, 1, 0), (Firework.Size.Y * 2), {Firework, Character})
			if DistanceApart >= 100 and not RayHit then
				if ExplosionType == 1 then
					HandleFirework(ClassicExplosion, Firework)
				elseif ExplosionType == 2 then
					HandleFirework(ImageExplosion, Firework)
				elseif ExplosionType == 3 then
					local FinalExplosionType = math.random(1, 2)
					if FinalExplosionType == 1 then
						HandleFirework(ClassicExplosion, Firework)
					else
						HandleFirework(ImageExplosion, Firework)
					end
				end
			else
				for ii, vv in pairs({BodyGyro, BodyVelocity}) do
					if vv and vv.Parent then
						vv:Destroy()
					end
				end
			end
		end
	end)
	wait(0.5)
end

Fire.Enabled = false

Smoke = Instance.new("Smoke")
Smoke.Opacity = 0.0625
Smoke.RiseVelocity = 0.001
Smoke.Size = 0.1
Smoke.Color = BrickColor.new((FireworkDud and "Medium stone grey") or "Institutional white").Color
Smoke.Enabled = true
Smoke.Parent = Pumpkin