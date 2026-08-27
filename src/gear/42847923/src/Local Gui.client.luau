local Tool = script.Parent
local anim = nil
local swoosh = nil

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\ArrowFarCursor.png"
	--wait(1)
	if anim ~= nil then anim:Play() end
	wait(.75)
	if swoosh ~= nil then swoosh:Play() end
	wait(.5)
	if swoosh ~= nil then swoosh:Play() end
	wait(.25)
	if anim ~= nil then anim:Stop() end
	--wait(3.5)
	mouse.Icon = "rbxasset://textures\\ArrowCursor.png"

	--while not Tool.Enabled do wait(.01) end

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
			anim = Humanoid:LoadAnimation(Tool:WaitForChild("R15xswordfast3"))
		else 
			anim = Humanoid:LoadAnimation(Tool:WaitForChild("xswordfast3"))
		end
		swoosh = Tool.Handle.Fire
		mouse.Icon = "rbxasset://textures\\ArrowCursor.png"
		mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	end
end

function onUnequippedLocal()
	if swoosh ~= nil then swoosh:Stop() end
	swoosh = nil

	if anim ~= nil then anim:Stop() end
	if anim ~= nil then anim:Destroy() end
	anim = nil
end

Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
