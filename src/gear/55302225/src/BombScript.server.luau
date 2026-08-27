local FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local candle = script.Parent
local initPos = candle.Position
local debris = game:GetService("Debris")
local particles = {}

force.Parent = candle

local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1, .5, 0), Color3.new(0, .5, 1), Color3.new(1,0,1), Color3.new(.1, .1, .1), Color3.new(1,1,0), Color3.new(0,1,1)}

for i = 1, 10 do
	force.force = candle.CFrame.lookVector * candle:GetMass() * 98 * 3
	wait(.1)
end

force:Remove()

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
sound.Parent = script.Parent
sound.Volume = 1
sound:Play()

local numOfParticles = 30
particles = {}

local bodyPos = Instance.new("BodyPosition")
bodyPos.P = 700
bodyPos.D = 750
bodyPos.maxForce = Vector3.new(1,1,1) * bodyPos.P

for j= 1, numOfParticles do
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	p.Transparency = 1
	p.CanCollide = false
	p.Position = candle.Position
	p.Velocity =  candle.Velocity
	debris:AddItem(p, 23)	
	local s = Instance.new("Sparkles")
	s.Color = colors[math.random(1, #colors)]
	s.Parent = p
	table.insert(particles, p)
	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0, 600, 0)
	f.Parent = p
	debris:AddItem(f, 3)
	local increment = (math.pi *2)/numOfParticles
	local angle = increment * j	
	local pos = Vector3.new(((p.Position.x - initPos.x) * math.cos(angle)) - ((p.Position.y - initPos.y) * math.sin(angle)) +initPos.x,
		((p.Position.x - initPos.x) * math.sin(angle)) + ((p.Position.y - initPos.y) * math.cos(angle)) + initPos.y,p.Position.z)	
	local bodyPosForce = bodyPos:clone()
	bodyPosForce.position = Vector3.new(pos.x,pos.y + 80, pos.z)
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.angularvelocity = Vector3.new(50,50,50)
	bodyAngularVelocity.P = 500
	bodyAngularVelocity.maxTorque = Vector3.new(1,1,1) * bodyAngularVelocity.P
	p.Parent = game.Workspace
	bodyPosForce.Parent = p
	bodyAngularVelocity.Parent = p
end

candle.Transparency = 1
wait(2)
candle:Remove()
wait(3)

for i = 1, #particles do
	particles[i].BodyPosition.position = Vector3.new(initPos.x, initPos.y + 10, initPos.z)
end

wait(3)
for i =1, #particles do
	particles[i].BodyPosition.position = Vector3.new(particles[i].Position.x + math.random(-40, 40), initPos.y + math.random(40, 80), particles[i].Position.z + math.random(-40, 40))
end

wait(2.0)
for i =1, #particles do
	for j = 1, 4 do
		local newSpark = particles[i]:clone()
		newSpark.BodyPosition.position = Vector3.new(particles[i].Position.x + math.random(-40, 40), initPos.y + math.random(0, 60), particles[i].Position.z + math.random(-40, 40))
		newSpark.Sparkles.Color = colors[math.random(1,#colors)]
		newSpark.Parent = game.Workspace
		debris:AddItem(newSpark, 5)
	end
end

wait(4.5)
local e = Instance.new("Explosion")
e.BlastPressure = 5
e.BlastRadius = 15
for i = 1, #particles do
	particles[i].BodyPosition:remove()
	local upForce = Instance.new("BodyForce")
	upForce.force = Vector3.new(0, 250, 0)
	upForce.Parent = particles[i]
end
wait(1)
for i = 1, #particles do
	local exp = e:clone()
	exp.Position = particles[i].Position
	exp.Parent = game.Workspace
	particles[i]:remove()
	if FuseSound then FuseSound:Play() end
	wait(0.2)
end
