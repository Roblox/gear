--Made by Luckymaxer

Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

if Humanoid then
	Humanoid.PlatformStand = true
	wait(0.5)
	Humanoid.PlatformStand = false
end

Debris:AddItem(script, 0.5)