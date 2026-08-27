--Made by Luckymaxer

Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Duration = script:FindFirstChild("Duration")

Rate = (1 / 60)

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

if not Humanoid or Humanoid.Health == 0 or not Duration or Duration.Value <= 0 then
	DestroyScript()
	return
end

while Humanoid.Health > 0 and Duration.Value > 0 do
	if Humanoid then
		Humanoid.WalkSpeed = 6
	end
	local Time = wait(Rate)
	Duration.Value = (Duration.Value - Time)
end

if Humanoid then
	Humanoid.WalkSpeed = 16
end

DestroyScript()