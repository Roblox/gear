--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:WaitForChild("Humanoid")

Debris = game:GetService("Debris")

Dance = script:WaitForChild("DanceAnim")

Humanoid.WalkSpeed = 0

DanceAnim = Humanoid:LoadAnimation(Dance)

if DanceAnim then
	DanceAnim:Play()
end

wait(4.5)

Humanoid.Sit = true

wait(0.5)

Humanoid.Sit = false

Humanoid.WalkSpeed = 16

Debris:AddItem(script, 0)