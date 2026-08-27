print("Burning" .. script.Parent.Name)
for i = 1, 8 do
	script.Parent.Humanoid:TakeDamage(2)
	wait(1.5)
end
script:remove()
