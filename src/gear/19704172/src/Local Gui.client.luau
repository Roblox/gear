Tool=script.Parent
function onEquippedLocal(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
end

Tool.Equipped:connect(onEquippedLocal)