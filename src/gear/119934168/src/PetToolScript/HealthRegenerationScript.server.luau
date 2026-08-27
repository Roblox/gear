function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
	while true do
		child = parent.ChildAdded:wait()
		if child.Name==childName then return child end
	end
end


-- Renegeration Script for the bot
-- Renegerates about 1% of max hp per second until it reaches max health
bot = script.Parent
Humanoid = waitForChild(bot, "Humanoid")

local regen = false

function regenerate() 
	if regen then return end
	-- Lock this function until the regeneration to max health is complete by using a boolean toggle
	regen = true
	while Humanoid.Health < Humanoid.MaxHealth do
		local delta = wait(1)
		local health = Humanoid.Health
		if health > 0 and health < Humanoid.MaxHealth then 
			-- This delta is for regenerating 1% of max hp per second instead of 1 hp per second
			delta = 0.01 * delta * Humanoid.MaxHealth
			health = health + delta
			Humanoid.Health = math.min(health, Humanoid.MaxHealth)			
		end
	end	
	-- release the lock, since the health is at max now, and if the character loses health again
	-- it needs to start regenerating 
	regen = false
end	

if Humanoid then 
	-- Better than a while true do loop since it only fires when the health actually changes
	Humanoid.HealthChanged:connect(regenerate)	
end
