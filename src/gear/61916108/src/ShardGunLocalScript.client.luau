script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function() script.Parent.Mouse1Down:FireServer(mouse.Hit) end)
	mouse.Button1Up:connect(function() script.Parent.Mouse1Up:FireServer(mouse.Hit) end)
end)