local hungryHumanoid = script.Parent

-- Waits for script.childName to exist then returns it
local function scriptWaitForChild(childName)
	while not script:FindFirstChild(childName) do wait() end
	return script[childName]
end

local eatAnimation = scriptWaitForChild("EatAnimation")

-- Feed the Humanoid this script is attached to, then remove their food and attach poisonScript
if hungryHumanoid and hungryHumanoid:IsA("Humanoid") and hungryHumanoid.Parent then
	local food = hungryHumanoid.Parent:FindFirstChild("Food")
	local eatAnimTrack = hungryHumanoid:LoadAnimation(eatAnimation)
	if eatAnimTrack then eatAnimTrack:Play() end
	
	wait(2.2) -- Nom nom nom
	if food then food:Destroy() end
end
wait(20)
script:Destroy()
