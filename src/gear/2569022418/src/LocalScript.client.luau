local tool = script.Parent

local activeTrack

local hold = tool:WaitForChild("Hold")
local r15Hold = tool:WaitForChild("R15Hold")

tool.Equipped:Connect(function()
	local hum = tool.Parent:FindFirstChildOfClass("Humanoid")
	local anim = hold
	if hum then
		if hum.RigType == Enum.HumanoidRigType.R15 then
			anim = r15Hold
		end
		
		activeTrack = hum:LoadAnimation(anim)
		activeTrack:Play()
	end
end)

tool.Unequipped:Connect(function()
	if activeTrack then
		activeTrack:Stop()
	end
	
	activeTrack = nil
end)