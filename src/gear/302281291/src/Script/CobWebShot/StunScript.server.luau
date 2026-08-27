--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

Duration = script:FindFirstChild("Duration")

Destroying = false

function DestroyScript()
	if Destroying then
		return
	end
	Destroying = true
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end
	Debris:AddItem(script, 0.5)
end

if not Humanoid or Humanoid.Health == 0 or not Humanoid:IsA("Humanoid") or not Duration or Duration.Value <= 0 then
	DestroyScript()
	return
end

Humanoid.WalkSpeed = 6

wait(Duration.Value)

DestroyScript()