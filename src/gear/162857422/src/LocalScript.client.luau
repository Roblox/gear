script.Parent.Equipped:connect(function(mouse)
	if script.Parent.Empty.Value then
		mouse.Icon = 'rbxasset://textures\\ArrowFarCursor.png'
	else
		mouse.Icon = 'rbxasset://textures\\ArrowCursor.png'
		
		mouse.Button1Down:connect(function()
			mouse.Icon = 'rbxasset://textures\\ArrowFarCursor.png'
		end)
	end
end)