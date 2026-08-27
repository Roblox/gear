wait()
sp = script.Parent

while script:FindFirstChild("CheckEye") == nil do
	wait()
end

local humanoid = sp:FindFirstChild("Humanoid")
if humanoid ~= nil then
	humanoid.WalkSpeed = 0 
	local salute = humanoid:LoadAnimation(script:FindFirstChild("CheckEye"))

	if salute then
		salute:Play()
	end

	sound = script.sSound
	if sp:FindFirstChild("Torso") ~= nil then
		sound.Parent = sp.Torso
	end
	wait(.1)
	sound:Play()
	wait(2.0)
	if salute then
		salute:Stop()
	end
	if sound ~= nil then
		sound:Stop()
		sound:remove()
	end
	humanoid.WalkSpeed = 16
	
end

script:remove()