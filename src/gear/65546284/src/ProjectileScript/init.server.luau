ball = script.Parent
damage = 9

hitSound = Instance.new("Sound")
hitSound.Name = "hitSound"
hitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
hitSound.Parent = ball
hitSound.Volume = 1

while script:FindFirstChild("ShurikenPierceScript") == nil do 
	wait()
end

function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	if hit.Parent.className == "Hat" then		
		humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
	end
	if humanoid ~= nil then
		if hitSound then hitSound:Play() end
		humanoid:TakeDamage(damage)
		if humanoid.Parent:FindFirstChild("ShurikenPierceScript") == nil then 
			local cloneScript = script.ShurikenPierceScript:Clone()
			cloneScript.Parent = humanoid.Parent 
			cloneScript.Disabled = false
		end
	end
	if connection then connection:disconnect() end
	ball.Velocity = Vector3.new(0, 0, 0) -- have the kunai drop dead upon impact
	ballFloat = ball:FindFirstChild("BodyForce")
	if ballFloat ~= nil then ballFloat:Destroy() end
end


connection = ball.Touched:connect(onTouched)

wait(4)
ball.Parent = nil
