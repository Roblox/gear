ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=13775466"
HitSound.Parent = ball
HitSound.Volume = 1



function onTouched(hit)
	if hit and hit.Parent then
		local humanoid = hit.Parent:findFirstChild("Humanoid")
	
		if humanoid ~= nil then
			tagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
			untagHumanoid(humanoid)
		end
	
		HitSound:Play()
		ball.Parent = nil
	end
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
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

connection = ball.Touched:connect(onTouched)

wait(5)
--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()
ball.Parent = nil