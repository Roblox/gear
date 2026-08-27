local Tool = script.Parent;
local anim = nil
enabled = true
local con = nil

function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false

	if anim then
		anim:Play()
	end
	Tool.mode.Value = math.random(1,9)

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
			anim = Humanoid:LoadAnimation(Tool:WaitForChild("R15Sax"))
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			anim = Humanoid:LoadAnimation(Tool:WaitForChild("saxtest"))
		end
	end	
	
	mouse.Icon = "http://www.roblox.com/asset/?id=1088199"
	con = mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end

function onUnequippedLocal()

	if anim ~= nil then
		anim:Stop()
		anim:Destroy()
	end
	if con ~= nil then
		con:disconnect()
	end

end

Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
