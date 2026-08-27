wait(0.5)

local banana = script.Parent

local touched = false

function onTouched(part)

	if touched then
		return
	end
	
	touched = true

	local humanoid = part.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil then

		banana.SlipSound:Play()
		humanoid.Jump = true
		humanoid.Sit = true
		wait(0.9)
		humanoid.Sit = false

	end

	touched = false

end

banana.Touched:connect(onTouched)
