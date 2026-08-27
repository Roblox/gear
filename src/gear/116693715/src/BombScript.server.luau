local Candle = script.Parent

local FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local BodyForce = Instance.new("BodyForce")
BodyForce.Parent = Candle

local InitPos = Candle.Position
local Debris = game:GetService("Debris")


local Particles = {}

local Explosion = Instance.new("Explosion")
Explosion.BlastPressure = 5
Explosion.BlastRadius = 15

local Colors = {
				Color3.new(1,0,0), 
				Color3.new(0,1,0), 
				Color3.new(0,0,1), 
				Color3.new(1, .5, 0), 
				Color3.new(0, .5, 1), 
				Color3.new(1,0,1), 
				Color3.new(.1, .1, .1), 
				Color3.new(1,1,0), 
				Color3.new(0,1,1)
			}

for i = 1, 10 do
	BodyForce.force = Candle.CFrame.lookVector * Candle:GetMass() * 98 * 3
	wait(.1)
end

BodyForce:Destroy()

local RocketSound = Instance.new("Sound")
RocketSound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
RocketSound.Parent = script.Parent
RocketSound.Volume = 1
RocketSound:Play()

local NumParticles = 50
Particles = {}

local BodyPosition = Instance.new("BodyPosition")
BodyPosition.P = 700
BodyPosition.D = 750
BodyPosition.maxForce = Vector3.new(1,1,1) * BodyPosition.P

for j = 1, NumParticles do
	local part = Instance.new("Part")
	part.Size = Vector3.new(1,1,1)
	part.Transparency = 1
	part.CanCollide = false
	part.Position = Candle.Position
	part.Velocity =  Candle.Velocity
	Debris:AddItem(part, 23)	

	local sparkle = Instance.new("Sparkles")	
	sparkle.Color = Colors[math.random(1, #Colors)]
	sparkle.Parent = part
	table.insert(Particles, part)
	
	
	if math.random() < 0.25 then 

		local pLight = Instance.new('PointLight')
		pLight.Color = Colors[math.random(1, #Colors)]
		pLight.Parent = part 
		pLight.Range = 60
	
		local sLight = Instance.new('SpotLight')
		sLight.Color = Colors[math.random(1, #Colors)]
		sLight.Parent = part 
		sLight.Range = 60
	end 


	local bForce = Instance.new("BodyForce")
	bForce.force = Vector3.new(0, 600, 0)
	bForce.Parent = part

	Debris:AddItem(bForce, 3)

	local increment = (math.pi *2)/NumParticles
	local angle = increment * j	
	local pos = Vector3.new(((part.Position.x - InitPos.x) * math.cos(angle)) - ((part.Position.y - InitPos.y) * math.sin(angle)) +InitPos.x,
		((part.Position.x - InitPos.x) * math.sin(angle)) + ((part.Position.y - InitPos.y) * math.cos(angle)) + InitPos.y, part.Position.z)	

	local bodyPosForce = BodyPosition:Clone()	
	bodyPosForce.position = Vector3.new(pos.x,pos.y + 80, pos.z)

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.angularvelocity = Vector3.new(50,50,50)
	bodyAngularVelocity.P = 500
	bodyAngularVelocity.maxTorque = Vector3.new(1,1,1) * bodyAngularVelocity.P

	part.Parent = game.Workspace
	bodyPosForce.Parent = part
	bodyAngularVelocity.Parent = part
end

Candle.Transparency = 1
wait(2)
Candle:Destroy()
wait(3)

for i = 1, #Particles do
	Particles[i].BodyPosition.position = Vector3.new(InitPos.x, InitPos.y + 10, InitPos.z)
end

wait(3)
for i =1, #Particles do
	Particles[i].BodyPosition.position = Vector3.new(Particles[i].Position.x + math.random(-40, 40), InitPos.y + math.random(40, 80), Particles[i].Position.z + math.random(-40, 40))
end

wait(2.0)
for i =1, #Particles do
	for j = 1, 4 do
		local newSpark = Particles[i]:clone()
		newSpark:WaitForChild("BodyPosition").position = Vector3.new(Particles[i].Position.x + math.random(-40, 40), InitPos.y + math.random(0, 60), Particles[i].Position.z + math.random(-40, 40))
		newSpark:WaitForChild("Sparkles").Color = Colors[math.random(1,#Colors)]
		newSpark.Parent = game.Workspace
		Debris:AddItem(newSpark, 5)
	end
end

wait(4.5)

for i = 1, #Particles do 
	if Particles[i] and Particles[i]:FindFirstChild('BodyPosition') then 
		Particles[i].BodyPosition:Destroy()
	end
	local upForce = Instance.new("BodyForce")
	upForce.force = Vector3.new(0, 250, 0)
	upForce.Parent = Particles[i]
end

wait(1)

for i = 1, #Particles do
	local exp = Explosion:clone()
	exp.Position = Particles[i].Position
	exp.Parent = game.Workspace
	Particles[i]:Destroy()
	if FuseSound then FuseSound:Play() end
	wait(0.2)
end
