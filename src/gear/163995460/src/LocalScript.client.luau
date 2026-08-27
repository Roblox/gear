local tool = script.Parent
tool.Equipped:connect(function(m)
	m.Button1Up:connect(function()
		tool.Click:FireServer()
	end)
end)