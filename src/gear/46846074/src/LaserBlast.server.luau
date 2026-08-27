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
		HitSound:Play()
		humanoid:TakeDamage(damage)
	end
	if connection then connection:disconnect() end
	ball.Velocity = Vector3.new(0, 0, 0) -- have the kunai drop dead upon impact
	ballFloat = ball:FindFirstChild("BodyForce")
	if ballFloat ~= nil then ballFloat:remove() end
end


connection = ball.Touched:connect(onTouched)

wait(4)
ball.Parent = nil
