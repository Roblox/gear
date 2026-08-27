while not script:FindFirstChild("Current") do wait() end

local myModel = script.Parent

-- Safely wait for petHumanoid
local petHumanoid = nil
if myModel then
	local aiScript = myModel:FindFirstChild("ChimeraAi")
	if aiScript then
		while not aiScript:FindFirstChild("Pet") do wait() end
		local pet = aiScript.Pet.Value
		if pet then
			petHumanoid = pet:FindFirstChild("Humanoid")
		end
	end
end

-- When Current is changed, tell petHumanoid to play the Animation there
if petHumanoid then
	script.Current.Changed:connect(function(newValue)
		if petHumanoid and newValue and newValue:IsA("Animation") then
			local animationTrack = petHumanoid:LoadAnimation(newValue)
			if animationTrack then animationTrack:Play() end
		end
	end)
end
