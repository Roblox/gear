local Tool = script.Parent;
local humanoid,anim = nil

local Animations = {
	Slingshot = Tool:WaitForChild("slingshot");
	R15Slingshot = Tool:WaitForChild("R15Slingshot")
}

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(.2)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)

	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = humanoid:LoadAnimation(Animations.R15Slingshot)
		else
			anim = humanoid:LoadAnimation(Animations.Slingshot)
		end
	end
end

Tool.Equipped:connect(onEquippedLocal)

function onUnequippedLocal()
	if anim then
		anim:Stop()
		anim:Destroy()
	end
end

Tool.Shooting.Changed:connect(function()

	if Tool.Shooting.Value == true then
		anim:Play()
	end

end)
