--Made by Luckymaxer

Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Duration = script:FindFirstChild("Duration")

if Duration then
	if Humanoid then
		Humanoid.WalkSpeed = 6
		Humanoid.PlatformStand = true
		wait(0.75)
		Humanoid.PlatformStand = false
	end
	while Duration.Value > 0 do
		local Delay = wait()
		Duration.Value = (Duration.Value - Delay)
	end
end

if Humanoid then
	Humanoid.WalkSpeed = 16
	Humanoid.PlatformStand = false
end

Debris:AddItem(script, 0.5)