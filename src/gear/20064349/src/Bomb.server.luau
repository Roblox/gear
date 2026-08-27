FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local shell = script.Parent

force.Parent = shell

local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)}

local smoke = Instance.new("Smoke")
smoke.Color = Color3.new(0,0,0)
smoke.Opacity = 1
smoke.RiseVelocity = 0
smoke.Size = .1
smoke.Parent = shell


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

for j=1,20 do

	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	--p.Transparency = 1
	p.Reflectance = 1
	p.Position = shell.Position + ( Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 10)
	p.Velocity =  shell.Velocity -- + (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 20)

	
	local s = Instance.new("Sparkles")
	s.Color = c
	s.Parent = p

	local f = Instance.new("BodyForce")
	f.force = Vector3.new(0,98,0)
	f.Parent = p

	p.Parent = game.Workspace


	local debris = game:GetService("Debris")
	debris:AddItem(p, 5)

end

local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
	sound.Parent = script.Parent
	sound.Volume = 1
	sound:play()

local e = Instance.new("Explosion")
e.BlastRadius = 16
e.BlastPressure = 150000
e.Position = shell.Position

-- find instigator tag
	local creator = script.Parent:findFirstChild("creator")
	if creator ~= nil then
		e.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

e.Parent = game.Workspace


shell.Transparency = 1
wait(2)
shell:Remove()
