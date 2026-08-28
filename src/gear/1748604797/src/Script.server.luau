-- // Created by StarWars

local tool = script.Parent

local humanoid = nil
local cacheSpeed = nil

local SPEED_BOOST = 24

function onEquipped()
	local character = tool.Parent
	humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if humanoid then
		cacheSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = SPEED_BOOST
	end
end

function onUnequipped()
	if humanoid then
		if cacheSpeed then
			humanoid.WalkSpeed = cacheSpeed
		end
	end
	
	humanoid = nil
	cacheSpeed = nil
end

tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)