local Tool = script.Parent;
local anim = nil

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\ArrowFarCursor.png"
	if anim then
		anim:Play()
	end
	wait(1)
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end
	local Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then	
			anim = Humanoid:LoadAnimation(Tool.R15BarrelThrow)
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			anim = Humanoid:LoadAnimation(Tool.barrelthrow)
		end
	end

	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end

Tool.Equipped:connect(onEquippedLocal)
