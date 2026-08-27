local hungryHumanoid = script.Parent

-- Waits for script.childName to exist then returns it
local function scriptWaitForChild(childName)
	while not script:FindFirstChild(childName) do wait() end
	return script[childName]
end

local poisonScript = scriptWaitForChild("Frogged")

-- Feed the Humanoid this script is attached to, then remove their food and attach poisonScript
if hungryHumanoid and hungryHumanoid:IsA("Humanoid") and hungryHumanoid.Parent then
	if poisonScript then
		local poisonScriptClone = poisonScript:Clone()
		poisonScriptClone.Parent = hungryHumanoid
		poisonScriptClone.Disabled = false
	end
end

script:Destroy()
