FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local shell = script.Parent

local debris = game:GetService("Debris")

force.Parent = shell

local colors = {Color3.new(1,0,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)}


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

local c = colors[math.random(1,#colors)]

local sparkles = {}

for j=1,20 do

	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	p.Transparency = 1
	p.CanCollide = false
	p.Position = shell.Position + ( Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 10)
	p.Velocity =  shell.Velocity
	debris:AddItem(p, 6)

	
	local s = Instance.new("Sparkles")
	s.Color = c
	s.Parent = p

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(math.random(-520,520),500,math.random(-520,520))
	f.Parent = p
	
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(p.Position.x + math.random(-10,10),p.Position.y + math.random(-20,-10),p.Position.z + math.random(-10,10))
	bodyPos.P = 500
	bodyPos.D = 550
	bodyPos.maxForce = Vector3.new(1,1,1) * bodyPos.P

	local bodyAngle = Instance.new("BodyAngularVelocity")
	bodyAngle.angularvelocity = Vector3.new(50,50,50)
	bodyAngle.P = 500
	bodyAngle.maxTorque = Vector3.new(1,1,1) * bodyAngle.P
	

	p.Parent = game.Workspace

	bodyPos.Parent = p
	bodyAngle.Parent = p

	table.insert(sparkles, p)

end

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
sound.Parent = script.Parent
sound.Volume = 1
sound:play()

shell.Transparency = 1
wait(2)
shell:Remove()

for i = 1, #sparkles do

	sparkles[i].BodyPosition:remove()
	local bodyForce = Instance.new("BodyForce")
	bodyForce.force = Vector3.new(math.random(-20,20),math.random(100,140),math.random(-20,20))
	force.Parent = sparkles[i]

end



