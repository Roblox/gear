local con

script.Parent.Equipped:connect(function(mouse)
	if con then con:disconnect() end
	
	con = script.Parent.SetMouseIcon.OnClientEvent:connect(function(icon)
		mouse.Icon = icon
	end)
end)
script.Parent.Unequipped:connect(function()
	if con then con:disconnect() end
end)