script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function() script.Parent.Click:FireServer(true, mouse.Hit.p) end)
	mouse.Button1Up:connect(function() script.Parent.Click:FireServer(false, mouse.Hit.p) end)
end)