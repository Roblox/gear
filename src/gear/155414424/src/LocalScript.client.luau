script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function() script.Parent.Input:FireServer('Mouse1', true, mouse.Hit) end)
	mouse.Button1Up:connect(function() script.Parent.Input:FireServer('Mouse1', false, mouse.Hit) end)
end)