Mine = script.Parent

DunDun = Instance.new("Sound")
DunDun.SoundId = "http://www.roblox.com/asset/?id=11984254"
DunDun.Parent = Mine

SubspaceExplosion = Instance.new("Sound")
SubspaceExplosion.SoundId = "http://www.roblox.com/asset/?id=11984351"
SubspaceExplosion.Parent = Mine

Calibrate = Instance.new("Sound")
Calibrate.SoundId = "http://www.roblox.com/asset/?id=11956590"
Calibrate.Looped = true
Calibrate.Parent = Mine
Calibrate:Play()

local calibration_time = 2 -- needs to be still/untouched for this long before calibrating
local cur_time = 0
local max_life = 120 -- these things last for 2 minutes on their own, once activated
local calibrated = false

local connection = nil

function activateMine()
	for i=0,1,.1 do
		Mine.Transparency = i
		wait(.05)
	end
	calibrated = true
	Calibrate:Stop()
end

function pulse()
	DunDun:Play()

	for i=.9,.5,-.1 do
		Mine.Transparency = i
		wait(.05)
	end

	for i=.5,1,.1 do
		Mine.Transparency = i
		wait(.05)
	end
end

function explode()
	connection:disconnect()

	for i=1,0,-.2 do
		Mine.Transparency = i
		wait(.05)
	end
	SubspaceExplosion:Play()

	local e = Instance.new("Explosion")
	e.BlastRadius = 16
	e.BlastPressure = 1000000
	e.Position = Mine.Position
	e.Parent = Mine

	local creator = script.Parent:findFirstChild("creator")

	e.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)


	for i=0,1,.2 do
		Mine.Transparency = i
		wait(.05)
	end
	wait(4)
	Mine:Remove()
end

function update()
	if (calibrated == false) then
		if (Mine.Velocity.magnitude > .05) then
			cur_time = 0
		end

		if (cur_time > calibration_time) then
			activateMine()
		end
	else
		-- calibrated mine
		if (math.random(1,20) == 2) then
			pulse()
		end

		if (cur_time > max_life) then pulse() Mine:Remove() end
	end
end


function OnTouch(part)
	if (calibrated == false) then
		cur_time = 0
	else
		explode()
	end
end


function onPlayerBlownUp(part, distance, creator)

	if (part:getMass() < 300) then
		part.BrickColor = BrickColor.new(1032)
		local s = Instance.new("Sparkles")
		s.Parent = part
		game.Debris:AddItem(s, 5)
	end
	

	if creator ~= nil and part.Name == "Head" then
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

connection = Mine.Touched:connect(OnTouch)


while true do
	update()
	local e,g = wait(.5)
	cur_time = cur_time + e
end





