--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Duration = 0.5

if Humanoid then
	Humanoid.WalkSpeed = 6
end

wait(Duration)

if Humanoid then
	Humanoid.WalkSpeed = 16
end


script:Destroy()