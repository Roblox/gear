local equipped = false

script.Parent.Equipped:connect(function(mouse)
	equipped = true
	mouse.Button1Down:connect(function() script.Parent.Input:FireServer('Mouse1', true) end)
	mouse.Button1Up:connect(function() script.Parent.Input:FireServer('Mouse1', false) end)
	mouse.KeyDown:connect(function(key) script.Parent.Input:FireServer('Key', true, key) end)
	
	while equipped do
		mouse.TargetFilter = script.Parent.Parent
		script.Parent.Input:FireServer('MouseUpdate', mouse.Hit)
		wait(1/20)
	end
end)

script.Parent.Unequipped:connect(function()
	equipped = false
end)