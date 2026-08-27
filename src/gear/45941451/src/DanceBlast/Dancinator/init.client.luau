local myChar = script.Parent
if script.Parent ~= nil then
	local myHum = script.Parent:FindFirstChild("Humanoid")
	if myHum ~= nil then
		newAnim = myHum:LoadAnimation(script.Boogie)
		newAnim:Play()
	end
	script.BoogieSound:Play()
	if myHum ~= nil then
		wait(4)
		myHum.Sit = true
		myTorso = script.Parent:FindFirstChild("Torso")
		local newBG = nil
		if myTorso ~= nil then
			newBG = Instance.new("BodyGyro")
			newBG.P = 100000
			newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
			newBG.cframe = myTorso.CFrame
			newBG.Parent = myTorso
		end
		wait(1)
		myHum.Sit = false
		if newBG ~= nil then newBG:remove() end
	end
end

wait(3)

script:remove()
