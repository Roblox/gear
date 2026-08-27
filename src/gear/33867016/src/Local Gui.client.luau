local Tool = script.Parent;
local anim = nil
local mouse = nil

Tool.Enable.Changed:connect(function()
	if mouse then
		if Tool.Enable.Value == true then
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		else
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		end
	end
end)

function onButton1Down(mouser)
	mouse = mouser
	if not Tool.Enable.Value then
		return
	end

	Tool.Enable.Value = false
	wait(3)
	if anim then
		anim:Play(0.1,1,2)
	end
	wait(8)
	mouse = mouser
	Tool.Enable.Value = true
end

function resetIcon()
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
end

function onEquippedLocal(mouser)
	
	mouse = mouser
	if mouse == nil then
		print("Mouse not found")
		return 
	end

	if Tool.Enable.Value == true then
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
	else
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		delay(8,resetIcon)
	end
	mouse.Button1Down:connect(function() onButton1Down(mouser) end)
	anim = script.Parent.Parent.Humanoid:LoadAnimation(Tool.kickback)

end

function onUnequippedLocal()

	if anim then
		anim:Stop()
		anim:remove()
		anim = nil
	end

end


Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)


