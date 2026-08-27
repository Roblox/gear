local fuseSound = Instance.new("Sound")
fuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
fuseSound.Parent = script.Parent
fuseSound:Play()

local force = Instance.new("BodyForce")
local rocket = script.Parent

force.Parent = rocket
local colors = {Vector3.new(1,0,0), Vector3.new(0,1,0), Vector3.new(0,0,1), Vector3.new(1, .5, 0), Vector3.new(0, .5, 1), Vector3.new(1,0,1), Vector3.new(.1, .1, .1), Vector3.new(1,1,0), Vector3.new(0,1,1)}

function onCharacterBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)	
	if creator ~= nil then
		local tag = creator:clone()
		tag.Parent = humanoid
		debris:AddItem(tag, 1)
	end
end

for i=1,14 do
	force.force = rocket.CFrame.lookVector * rocket:GetMass() * 98 * -3	
	wait(.1)
end

force:Remove()

local c = colors[math.random(1,#colors)]
local c2 = colors[math.random(1, #colors)]
local c3 = colors[math.random(1, #colors)]
local c4 = colors[math.random(1, #colors)]
local c5 = colors[math.random(1, #colors)]
local c6 = colors[math.random(1, #colors)]
local rad = 10
local vel = 50
local rocketPos = rocket.Position

local sparkleList = {}

local fireworkFactor = (math.random()-.5)*4 + 1

print(fireworkFactor)

for j = 0,14 do
	for k = 1, 2 do
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)

	p.Transparency = 1	
	p.CanCollide = true

	angle = (j*2+k) * math.pi / 10
	p.Position = rocket.Position + Vector3.new(math.sin(angle)*rad, 1, math.cos(angle)*rad)
	p.Velocity =  rocket.Velocity 
	
	local s = Instance.new("Fire")	
	s.Color = Color3.new(c)
	if k == 2 then s.Color = Color3.new(c2) end
	s.SecondaryColor = Color3.new(colors[math.random(1, #colors)])
	s.Parent = p
	table.insert(sparkleList, s)

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0,180,0)
	f.Parent = p

	tanVect = Vector3.new(rocketPos.X - p.Position.X, 0, rocketPos.Z - p.Position.Z).unit
	p.Velocity = tanVect:Cross(Vector3.new(0,1,0))*vel
	if k == 2 then p.Velocity = fireworkFactor * p.Velocity end
	p.Parent = game.Workspace
	local debris = game:GetService("Debris")
	debris:AddItem(p, 7)
	end
end

function updateParticles(time)
	for a = 0, 14 do
		for b = 1, 2 do
			mySpark = sparkleList[a*2+b]
			if mySpark ~= nil then 
				if mySpark.Parent then mySpark.Parent.BodyForce.force = ((rocketPos - mySpark.Parent.Position)*Vector3.new(1,0,1)).unit * vel*vel/rad + Vector3.new(0, 240, 0)  end
				if b == 1 then 
					newColor = c*(1-time) + c3*time
					mySpark.Color = Color3.new(newColor.X, newColor.Y, newColor.Z)
				else
					newColor = c2*(1-time) + c4*time
					mySpark.Color = Color3.new(newColor.X, newColor.Y, newColor.Z)
				end
			end
		end
	end
end

function updateParticles2(time)
	for a = 0, 14 do
		for b = 1, 2 do
			mySpark = sparkleList[a*2+b]
			if mySpark ~= nil then 
				if mySpark.Parent then mySpark.Parent.BodyForce.force = ((rocketPos - mySpark.Parent.Position)*Vector3.new(1,0,1)).unit * vel*vel/rad + Vector3.new(0, 240, 0)  end
				if b == 1 then 
					newColor = c3*(1-time) + c5*time
					mySpark.Color = Color3.new(newColor.X, newColor.Y, newColor.Z)
				else
					newColor = c4*(1-time) + c6*time
					mySpark.Color = Color3.new(newColor.X, newColor.Y, newColor.Z)
				end
			end
		end
	end
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
sound.Parent = script.Parent
sound.Volume = 1
sound:play()

local e = Instance.new("Explosion")
e.BlastRadius = 3
e.BlastPressure = 150000
e.Position = rocket.Position
local creator = script.Parent:findFirstChild("creator")
if creator ~= nil then
	e.Hit:connect(function(part, distance) onCharacterBlownUp(part, distance, creator) end)
end
e.Parent = game.Workspace
rocket.Transparency = 1
for i = 1, 30 do
	updateParticles(i/20)
	wait(.1)
end
rocket:Remove()
for i = 1, 30 do
	updateParticles2(i/20)
	wait(.1)
end
