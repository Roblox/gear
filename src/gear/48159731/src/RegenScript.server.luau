--Fixed by Luckymaxer

Tool = script.Parent

Growth = Tool:WaitForChild("Growth")

Healing = false

Growth.Changed:connect(function()
	if Healing then
		return
	end
	Healing = true
	while Growth.Value >= 6 do
		local Character = Tool.Parent
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid.Health > 0 and Humanoid.MaxHealth > (Humanoid.Health + 3) then
			Humanoid.Health = (Humanoid.Health + 3)
		end
		wait(1)
	end
	Healing = false
end)