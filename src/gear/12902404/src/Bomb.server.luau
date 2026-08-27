FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local total_time = 5 -- seconds
local cur_time = 0

function update(frac)
	script.Parent.Fuse.Color = Color3.new(1,1 - frac,0)
end


function blowUp()
	local sound = Instance.new("Sound")
		sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
		sound.Parent = script.Parent
		sound.Volume = 1
		sound:play()

	for i=1,3 do
		explosion = Instance.new("Explosion")
		explosion.BlastRadius = 12
		explosion.BlastPressure = 1000000 -- these are really wussy units

		-- find instigator tag
		local creator = script.Parent:findFirstChild("creator")
		if creator ~= nil then
			explosion.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
		end

		explosion.Position = script.Parent.Position + Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)
		explosion.Parent = game.Workspace
		wait(.1)
	end
	script.Parent.Transparency = 1
end

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

while cur_time < total_time do
	update(cur_time / total_time)
	local e,g = wait(.5)
	cur_time = cur_time + e
end


blowUp()
wait(.1)
script.Parent:remove()
