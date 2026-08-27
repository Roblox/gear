--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

if Humanoid then
	Humanoid.WalkSpeed = (math.abs(Humanoid.WalkSpeed) * -1)
	wait(2.5)
	Humanoid.WalkSpeed = (math.abs(Humanoid.WalkSpeed) * 1)
end

Debris:AddItem(script, 0.5)
script:Destroy()