--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Duration = script:WaitForChild("Duration")

Rate = (1 / 60)

Humanoid.WalkSpeed = 6

while Duration.Value > 0 do
	local Time = wait(Rate)
	Duration.Value = (Duration.Value - Time)
	wait(Rate)
end

Humanoid.WalkSpeed = 16

script:Destroy()