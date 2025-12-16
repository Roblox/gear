script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function()
		script.Parent.MouseClick.Value = not script.Parent.MouseClick.Value
	end)
end)