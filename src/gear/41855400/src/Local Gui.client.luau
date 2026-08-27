local Tool = script.Parent;
local anim = nil
local humanoid = nil

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\ArrowFarCursor.png"
	anim:Play()
	wait(6)
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end
	
	humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(Tool:WaitForChild("R15Drink"))
		else
			anim = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(Tool:WaitForChild("drink"))
		end
	end
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end

function onUnequippedLocal()

	anim:Stop()
	anim:remove()
	anim = nil

end

Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
