-- Poison the Humanoid this script is attached to
-- While poisoned, victim is slower, takes damage, and flickers green

local victim = script.Parent

if victim and victim:IsA("Humanoid") and victim.Parent then
	local victimChildren = victim.Parent:GetChildren()

	local originalColors = {}
	for i = 1, #victimChildren do -- Save original colors
		local child = victimChildren[i]
		if child and child:IsA("Part") then
			originalColors[i] = child.BrickColor
		end
	end

	local originalWalkSpeed = victim.WalkSpeed
	victim.WalkSpeed = 10

	for index = 1, 10 do -- Should be thought of as turning on and off 5 times
		if not victim or victim.Health <= 0 then break end
		for i = 1, #victimChildren do -- Color all parts green / Restore original colors
			local child = victimChildren[i]
			if child and child:IsA("Part") then
				if index % 2 ~= 0 then
					child.BrickColor = BrickColor.new(119) -- ("Br. yellowish green")
				else
					child.BrickColor = originalColors[i]
				end
			end
		end
		if index % 2 ~= 0 then
			victim:TakeDamage(victim.MaxHealth / 8) -- (12.5 normally, so 62.5 total)
		end
		wait(1)
	end

	if victim then victim.WalkSpeed = originalWalkSpeed end
end

script:Destroy()
