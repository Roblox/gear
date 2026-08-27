FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyGyro")
local shell = script.Parent

--force.cframe = shell.CFrame
force.cframe = CFrame.new()*CFrame.Angles(-math.pi/2,0,0)
force.P = 10000
force.maxTorque = Vector3.new(force.P, force.P, force.P)

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

--- BOOM!

local sparkleList = {}
local rad = 3
local vel = 10

local specialColor = colors[math.random(1, #colors)] -- by the end, will all be 1 color

for j=0,19 do
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)

	p.Transparency = 1
	--p.Reflectance = 1
	p.CanCollide = true

	angle = j * math.pi / 10
	p.Position = shell.Position + Vector3.new(math.sin(angle)*rad, rad/2, math.cos(angle)*rad)
	p.Velocity =  shell.Velocity + Vector3.new(math.sin(angle)*vel,vel*2,math.cos(angle)*vel) -- + (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 20)
	
	--local s = Instance.new("Sparkles")
	local s = Instance.new("Sparkles")

	--s.Color = Color3.new(c)
	--if k == 2 then s.Color = Color3.new(c2) end
	tempColor = colors[math.random(1, #colors)]
	s.Color = Color3.new(tempColor.X, tempColor.Y, tempColor.Z)

	--s.SecondaryColor = colors[math.random(1, #colors)]
	s.Parent = p

	table.insert(sparkleList, s)

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0,180,0)
	f.Parent = p

	p.Parent = game.Workspace

	local debris = game:GetService("Debris")
--	debris:AddItem(p, 5)
	debris:AddItem(p, 17)
end

function updateSparkles(time)
	for a = 1, 20 do
		local angle = a * math.pi / 10
		mySpark = sparkleList[a]
		if mySpark ~= nil and mySpark.Parent ~= nil and shell ~= nil then 
			mySpark.Parent.Position = shell.Position + Vector3.new(math.sin(angle)*rad, rad, math.cos(angle)*rad)
			mySpark.Parent.Velocity =  shell.Velocity + Vector3.new(math.sin(angle)*vel,vel*2,math.cos(angle)*vel)
			
			--newColor = c2*(1-time) + c4*time
			newColor = colors[math.random(1, #colors)] * (1-time*time) + specialColor*time*time
			mySpark.Color = Color3.new(newColor.X, newColor.Y, newColor.Z)
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

--e.Parent = game.Workspace

--shell.Transparency = 1
for i = 1, 10 do
	updateSparkles(i/10)
	wait(1.5)
end

shell:Remove()
