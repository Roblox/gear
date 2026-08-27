local tool = script.Parent

tool.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function()
		tool.Input:FireServer('MB1', true, mouse.Hit.p)
	end)
end)