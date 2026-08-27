ball = script.Parent

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1



function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local hasDanceAlready = hit.Parent:FindFirstChild("Dancinator")

	if hasDanceAlready then return end

	if humanoid ~= nil then
		HitSound:Play()
		dancinator = script.Dancinator
		dancinator.Parent = hit.Parent
		dancinator.Disabled = false
		connection:disconnect()
		ball.Parent:remove()
	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
end


connection = ball.Touched:connect(onTouched)

wait(6)
ball.Parent:remove()
