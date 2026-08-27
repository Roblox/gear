FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local shell = script.Parent
local initPos = shell.Position
local debris = game:GetService("Debris")
local sparkles = {}

force.Parent = shell

local colors = {Color3.new(0,0,1), Color3.new(0,1,0)}


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
	force.force = shell.CFrame.lookVector * shell:GetMass() * 98 * 3
	wait(.1)
end

force:Remove()

--- BOOM!

local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
	sound.Parent = script.Parent
	sound.Volume = 1
	sound:play()

local numOfSparkles = 30
sparkles = {}

local bodyPos = Instance.new("BodyPosition")
bodyPos.P = 500
bodyPos.D = 550
bodyPos.maxForce = Vector3.new(1,1,1) * bodyPos.P

-- this is incredibly messy........ happy 4th of July! :)
for j=1,numOfSparkles do

	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	p.Transparency = 1
	p.CanCollide = false
	p.Position = shell.Position
	p.Velocity =  shell.Velocity
	debris:AddItem(p, 23)
	
	local s = Instance.new("Sparkles")
	s.Color = colors[math.random(1,#colors)]
	s.Parent = p

	table.insert(sparkles,p)

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0,600,0)
	f.Parent = p
	debris:AddItem(f, 3)

	local increment = (math.pi *2)/numOfSparkles
	local angle = increment * j
	
	local pos = Vector3.new(((p.Position.x - initPos.x) * math.cos(angle)) - ((p.Position.y - initPos.y) * math.sin(angle)) +initPos.x,
		((p.Position.x - initPos.x) * math.sin(angle)) + ((p.Position.y - initPos.y) * math.cos(angle)) + initPos.y,p.Position.z)
	
	local bodyPosForce = bodyPos:clone()
	bodyPosForce.position = Vector3.new(pos.x,pos.y + 80, pos.z)

	local bodyAngle = Instance.new("BodyAngularVelocity")
	bodyAngle.angularvelocity = Vector3.new(50,50,50)
	bodyAngle.P = 500
	bodyAngle.maxTorque = Vector3.new(1,1,1) * bodyAngle.P
	

	p.Parent = game.Workspace

	bodyPosForce.Parent = p
	bodyAngle.Parent = p

end

shell.Transparency = 1
wait(2)
shell:Remove()

wait(3)

for i = 1, #sparkles do
	sparkles[i].BodyPosition.position = Vector3.new(initPos.x,initPos.y + 10, initPos.z)
end

wait(4)

for i =1, #sparkles do
	sparkles[i].BodyPosition.position = Vector3.new(sparkles[i].Position.x + math.random(-50,50), initPos.y + math.random(50,100), sparkles[i].Position.z + math.random(-50,50))
end

wait(2.5)

for i =1, #sparkles do

	for j = 1,3 do
		local newSpark = sparkles[i]:clone()
		newSpark.BodyPosition.position = Vector3.new(sparkles[i].Position.x + math.random(-50,50), initPos.y + math.random(-10,50), sparkles[i].Position.z + math.random(-50,50))
		newSpark.Sparkles.Color = colors[math.random(1,#colors)]
		newSpark.Parent = game.Workspace
		debris:AddItem(newSpark,5)
	end

end

wait(5)

local e = Instance.new("Explosion")
e.BlastPressure = 5
e.BlastRadius = 10

for i = 1, #sparkles do

	sparkles[i].BodyPosition:remove()
	local upForce = Instance.new("BodyForce")
	upForce.force = Vector3.new(0,240,0)
	upForce.Parent = sparkles[i]
end

wait(1)

for i = 1, #sparkles do

	local exp = e:clone()
	exp.Position = sparkles[i].Position
	exp.Parent = game.Workspace
	sparkles[i]:remove()
	wait(0.3)

end
