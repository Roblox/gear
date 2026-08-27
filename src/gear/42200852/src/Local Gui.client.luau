local Tool = script.Parent;
local anim = nil

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\ArrowFarCursor.png"
	--anim:Play()
	wait(16)
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end
	--anim = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(Tool.drink)
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end

function onUnequippedLocal()

	--anim:Stop()
	--anim:remove()
	--anim = nil

end

Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
