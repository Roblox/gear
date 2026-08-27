--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

if Humanoid and Humanoid.Health > 0 then
	Humanoid.WalkSpeed = -10
	wait(10)
	Humanoid.WalkSpeed = 16
end

Debris:AddItem(script, 0.5)