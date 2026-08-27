local Tool = script.Parent
local cast = nil

Mouse_Icon = "rbxasset://textures/GunCursor.png"
Reloading_Icon = "rbxasset://textures/GunWaitCursor.png"
local Mouse = nil

local enabled = false

local ServerControls = Tool:WaitForChild("ServerControls")
ServerControls.OnClientEvent:Connect(function()
	if cast then
		cast:Play()
	end
end)

function UpdateIcon()
	if Mouse then
		Mouse.Icon = Tool.Enabled and Mouse_Icon or Reloading_Icon
	end
end

function onEquippedLocal(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end	
	Mouse = mouse
	UpdateIcon()
	local Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		cast = Humanoid:LoadAnimation(Tool:WaitForChild("wandcast"))
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			cast = Humanoid:LoadAnimation(Tool:WaitForChild("R15wandcast"))
		end
	end
end

function onUnequippedLocal()
	if cast then
		cast:Stop()
		cast:Destroy()
	end
	cast = nil
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)