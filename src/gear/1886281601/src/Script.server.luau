-- // Created by StarWars
local tool = script.Parent

local character
local humanoid
local cacheWalkspeed = 16

tool.Equipped:Connect(function()
	character = tool.Parent
	humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		cacheWalkspeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 24 
	end
end)

tool.Unequipped:Connect(function()
	if humanoid then
		humanoid.WalkSpeed = cacheWalkspeed
	end
end)