ball = script.Parent
damage = 5

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

function onTouched(hit)
if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		if tostring(ball.creator.Value) ~= humanoid.Parent.Name then
--		tagHumanoid(humanoid)
--		humanoid:TakeDamage(damage)
--		untagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
			ball.Parent = nil
		end
	end

	if hit:findFirstChild("EnergyOrb") ~= nil then
		if tostring(hit.creator.Value) ~= tostring(ball.creator.Value) then
			ball.Parent = nil
		end
	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
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