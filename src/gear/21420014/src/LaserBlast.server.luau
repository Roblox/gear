ball = script.Parent
damage = 7

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1
HitSound.Pitch = .8

debris = game:GetService("Debris")


local hits = 7

function onTouched(hit)

	if (hit.Name == "ScatterShot") then return end

	hits = hits - 1
	if (hits < 0) then
		connection:disconnect()
		debris:AddItem(ball, .5)
	end

	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
		untagHumanoid(humanoid)
	end

	if (math.random() > .1) then
		HitSound:Play()
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