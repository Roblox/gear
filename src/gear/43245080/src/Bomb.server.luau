FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local shell = script.Parent

force.Parent = shell

--local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)}
--local colors = {Vector3.new(1,0,0), Vector3.new(0,1,0), Vector3.new(0,0,1), Vector3.new(1, .5, 0), Vector3.new(0, .5, 1)}
local colors = {Vector3.new(1,0,0), Vector3.new(0,1,0), Vector3.new(0,0,1), Vector3.new(1, .5, 0), Vector3.new(0, .5, 1), Vector3.new(1,0,1), Vector3.new(.1, .1, .1), Vector3.new(1,1,0), Vector3.new(0,1,1)}

--local smoke = Instance.new("Smoke")
--smoke.Color = Color3.new(0,0,0)
--smoke.Opacity = 1
--smoke.RiseVelocity = 0
--smoke.Size = .1
--smoke.Parent = shell


function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	-- tag does not need to expire iff all explosions lethal
	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

for i=1,10 do
	force.force = shell.CFrame.lookVector * shell:GetMass() * 98 * -3
	--force.force = shell:GetMass()*98*3*Vector3.new(0,1,0)
	wait(.1)
end

force:Remove()

--- BOOM!

local c = colors[math.random(1,#colors)]
local c2 = colors[math.random(1, #colors)]
local c3 = colors[math.random(1, #colors)]
local c4 = colors[math.random(1, #colors)]
local c5 = colors[math.random(1, #colors)]
local c6 = colors[math.random(1, #colors)]
--local sparkleList = {}

local rad = 10
local vel = 50
local shellPos = shell.Position

local sparkleList = {}

local fireworkFactor = (math.random()-.5)*4 + 1

print(fireworkFactor)

for j=0,9 do
	for k = 1, 2 do
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)

	p.Transparency = 1
	--p.Reflectance = 1
	p.CanCollide = true

	angle = (j*2+k) * math.pi / 10
	p.Position = shell.Position + Vector3.new(math.sin(angle)*rad, 1, math.cos(angle)*rad)
	p.Velocity =  shell.Velocity -- + (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 20)

	
	local s = Instance.new("Sparkles")
	--s.Color = c
	s.Color = Color3.new(c)
	if k == 2 then s.Color = Color3.new(c2) end
	--s.SecondaryColor = colors[math.random(1, #colors)]
	s.Parent = p

	table.insert(sparkleList, s)

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0,180,0)
	f.Parent = p

	tanVect = Vector3.new(shellPos.X - p.Position.X, 0, shellPos.Z - p.Position.Z).unit
	p.Velocity = tanVect:Cross(Vector3.new(0,1,0))*vel
	if k == 2 then p.Velocity = fireworkFactor*p.Velocity end

	p.Parent = game.Workspace


	local debris = game:GetService("Debris")
	debris:AddItem(p, 5)
	end

end

function updateSparkles(time)
	for a = 0, 9 do
		for b = 1, 2 do
			mySpark = sparkleList[a*2+b]
			if mySpark ~= nil then 
				mySpark.Parent.BodyForce.force = ((shellPos - mySpark.Parent.Position)*Vector3.new(1,0,1)).unit * vel*vel/rad + Vector3.new(0, 180, 0) 
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

function updateSparkles2(time)
	for a = 0, 9 do
		for b = 1, 2 do
			mySpark = sparkleList[a*2+b]
			if mySpark ~= nil then 
				mySpark.Parent.BodyForce.force = ((shellPos - mySpark.Parent.Position)*Vector3.new(1,0,1)).unit * vel*vel/rad + Vector3.new(0, 180, 0) 
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
--e.BlastRadius = 16
--e.BlastPressure = 150000
e.BlastRadius = 3
e.BlastPressure = 150000
e.Position = shell.Position

-- find instigator tag
	local creator = script.Parent:findFirstChild("creator")
	if creator ~= nil then
		e.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

e.Parent = game.Workspace

shell.Transparency = 1

for i = 1, 20 do
	updateSparkles(i/20)
	wait(.1)
end
--wait(2)
shell:Remove()
for i = 1, 20 do
	updateSparkles2(i/20)
	wait(.1)
end
