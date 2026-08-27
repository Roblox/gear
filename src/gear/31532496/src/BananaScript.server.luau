local banana = script.Parent
banana.Sound:Stop()

wait(3)

local touched = false

function onTouched(part)

	if touched then
		return
	end
	
	touched = true

	local humanoid = part.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil then

		banana.Sound:Play()
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.new(204/255,1,102/255)
		smoke.Parent = banana

		wait(5)
		banana:remove()

	end

	wait(3)

	touched = false

	

end

banana.Touched:connect(onTouched)
