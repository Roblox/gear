-- Poison the humanoid this script is attached to
local victim = script.Parent
if victim and victim:IsA("Humanoid") then
	local victimHead = victim.Parent:FindFirstChild("Head")
	local originalColor = victimHead.BrickColor
	for i = 1, 5 do
		if not victimHead or not victim or victim.Health <= 0 then break end
		victimHead.BrickColor = BrickColor.new("Lime green")
		victim:TakeDamage(5)
		wait(1.5)
		if not victimHead then break end
		victimHead.BrickColor = originalColor
		wait(1.5)
	end
end
script:Destroy()
