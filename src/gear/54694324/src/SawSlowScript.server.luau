Humanoid = script.Parent:FindFirstChild("Humanoid")
if not Humanoid then script:Remove() end

for i = 1, 5 do
	Humanoid:TakeDamage(4)
	Humanoid.WalkSpeed = Humanoid.WalkSpeed - 2
	wait(1)
end

Humanoid.WalkSpeed = 16
script:Remove()
