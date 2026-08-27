--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

if Character and Humanoid then
	local OrigSpeed = Humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	wait(2)
	Humanoid.WalkSpeed = OrigSpeed
end

Debris:AddItem(script, 2)