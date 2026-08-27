health = 3
active = false
script.Parent.Equipped:connect(function()
	active = true
end)
script.Parent.Unequipped:connect(function()
	active = false
end)
while wait(1) do
	if active then
		script.Parent.Parent.Humanoid.Health = script.Parent.Parent.Humanoid.Health + health
	end
end
		