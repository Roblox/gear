Tool=script.Parent
function onEquippedLocal(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() Tool.Mouse1:FireServer(true, mouse.Hit.p) end)
end

Tool.Equipped:connect(onEquippedLocal)