FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local Tool = script.Parent;
local redColor = Vector3.new(1,0,0)
local normalColor = Vector3.new(1,1,1)

local total_time = 5 -- seconds
local cur_time = 0

local bombWarmUp = 0

while bombWarmUp < 12 do
	
	if(Tool.EggMesh.VertexColor == normalColor )then
		Tool.EggMesh.VertexColor = redColor
	else
		Tool.EggMesh.VertexColor = normalColor
	end
	wait(0.5)
	bombWarmUp = bombWarmUp + 1
end

function onTouched(part)
	
	local h = part.Parent:findFirstChild("Humanoid")
	if h ~= nil then
		blowUp()
	end
end

Tool.Touched:connect(onTouched)

function blowUp()
	local sound = Instance.new("Sound")
		sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
		sound.Parent = script.Parent
		sound.Volume = 1
		sound:play()
	explosion = Instance.new("Explosion")
	explosion.BlastRadius = 12
	explosion.BlastPressure = 1000000 -- these are really wussy units

	-- find instigator tag
	local creator = script.Parent:findFirstChild("creator")
	if creator ~= nil then
		explosion.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

	explosion.Position = script.Parent.Position
	explosion.Parent = game.Workspace
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
--[[
while cur_time < total_time do
	update(cur_time / total_time)
	local e,g = wait(.5)
	cur_time = cur_time + e
end
--]]

--[[blowUp()
wait(.1)
script.Parent:remove()
--]]