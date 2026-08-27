--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Torso = Character:FindFirstChild("Torso")

Debris = game:GetService("Debris")

Duration = script:FindFirstChild("Duration")

Rate = 1

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Humanoid or Humanoid.Health == 0 or not Torso or not Duration or Duration.Value <= 0 then
	DestroyScript()
	return
end

Sparkles = Instance.new("Sparkles")
Sparkles.SparkleColor = BrickColor.new("Lime green").Color
Sparkles.Enabled = true
Sparkles.Parent = Torso

Humanoid.WalkSpeed = 24

while true do
	local Time = wait(1)
	Duration.Value = (Duration.Value - Time)
	if Duration.Value <= Time then
		if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
			Humanoid.WalkSpeed = 16
		end
		if Sparkles and Sparkles.Parent then
			Sparkles:Destroy()
		end
		DestroyScript()
		break
	end
end

