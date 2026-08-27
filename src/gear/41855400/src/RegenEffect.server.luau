function waitForChild(parent, childName)
        local child = parent:findFirstChild(childName)
        if child then return child end
        while true do
        child = parent.ChildAdded:wait()
        if child.Name==childName then return child end
        end
        end

        -- declarations

        local Figure = script.Parent
        local Head = waitForChild(Figure, "Head")
        local Humanoid = waitForChild(Figure, "Humanoid")

		if Figure:FindFirstChild("Health") ~= nil then
			Figure.Health.Disabled = true -- disable old health script for a bit

        -- regeneration (for 10 seconds at 2x speed)
        for i = 1, 10 do
        local s = wait(1)
        local health = Humanoid.Health
        if health > 0 and health < Humanoid.MaxHealth then
        health = health + 0.02 * s * Humanoid.MaxHealth
        if health * 1.05 < Humanoid.MaxHealth then
        Humanoid.Health = health
        else
        Humanoid.Health = Humanoid.MaxHealth
        end
        end
        end
      
		  Figure.Health.Disabled = false  -- reenable old health script
		end

script.Parent = nil  -- we're done here; so kill the effect script


--[[
-- assume we are in the character, let's check
function sepuku()
	script.Parent = nil
end

local h = script.Parent:FindFirstChild("Humanoid")
if (h == nil) then sepuku() end

local torso = script.Parent:FindFirstChild("Torso")
if (torso == nil) then sepuku() end

local head = script.Parent:FindFirstChild("Head")
if (head == nil) then head = torso end

-- increase regen for 10 seconds
for i = 1, 10 do
	local newHealth = h.Health + .01*h.MaxHealth*wait(1)
	if newHealth * 1.05 > h.MaxHealth then newHealth = h.MaxHealth end
	h.Health = newHealth
end

sepuku()
]]--