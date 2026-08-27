-- Burn the humanoid this script is attached to
local victim = script.Parent
if victim and victim:IsA("Humanoid") then
	local fire = Instance.new("Fire")
	fire.Parent = victim.Parent:FindFirstChild("Torso") or victim.Parent:FindFirstChild("UpperTorso")
	for i = 1, 8 do
		if not fire or not fire.Enabled or not victim or victim.Health <= 0 then break end
		victim:TakeDamage(2)
		wait(1.5)
	end
	if fire then fire:Destroy() end
end
script:Destroy()
