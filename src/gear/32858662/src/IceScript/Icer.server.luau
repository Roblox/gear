local origSpeed = script.Parent.Humanoid.WalkSpeed
script.Parent.Humanoid.WalkSpeed = script.Parent.Humanoid.WalkSpeed - 5
for i = 1, 8 do
	script.Parent.Humanoid:TakeDamage(1.2)
	wait(1.5)
end
script.Parent.Humanoid.WalkSpeed = origSpeed
script:remove()
