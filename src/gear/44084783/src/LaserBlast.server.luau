ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1



function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		HitSound:Play()
		humanoid:TakeDamage(damage)
		ball.Parent = nil
	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
end


connection = ball.Touched:connect(onTouched)

wait(4)
ball.Parent = nil
