Humanoid = script.Parent
OriginalWalkSpeed = Humanoid.WalkSpeed
Humanoid.WalkSpeed = (OriginalWalkSpeed / 2)
Duration = script:WaitForChild("Duration")
while Duration.Value > 0 do
	wait(1)
	Duration.Value = Duration.Value - 1
end
Humanoid.WalkSpeed = OriginalWalkSpeed
script:Destroy()