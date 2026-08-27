--Made by Luckymaxer

Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Torso = Character:FindFirstChild("Torso")

Duration = script:FindFirstChild("Duration")
Speed = script:FindFirstChild("Speed")

function DestroyScript()
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end
	Debris:AddItem(script, 0.5)
end

if not Humanoid or not Duration or Duration.Value <= 0 or not Speed then
	DestroyScript()
	return
end

if Torso then
	Sparkles = Instance.new("Sparkles")
	Sparkles.SparkleColor = Color3.new((85 / 255), (255 / 255), (255 / 255))
	Sparkles.Enabled = true
	Sparkles.Parent = Torso
end

Humanoid.WalkSpeed = Speed.Value

wait(Duration.Value)

if Sparkles then
	Debris:AddItem(Sparkles, 1)
	Sparkles.Enabled = false
end

Humanoid.WalkSpeed = 16

DestroyScript()