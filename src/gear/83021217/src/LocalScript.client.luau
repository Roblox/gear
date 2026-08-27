local Tool = script.Parent
local GetMousePosition = Tool:WaitForChild("GetMousePosition")
local LastUse = Tool:WaitForChild("LastUse")

local CurrentMouse = nil

local COOLDOWN_TIME = 3

function GetMousePosition.OnClientInvoke()
	if not CurrentMouse then return Vector3.new(0, 0, 0) end
	return CurrentMouse.Hit.p
end

function OnEquipped(mouse)
	CurrentMouse = mouse
	if Tool.Enabled then
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
	else
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		wait(LastUse.Value - (tick() - COOLDOWN_TIME))
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
	end	
	
	mouse.Button1Down:Connect(function()
		if not Tool.Enabled then
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			wait(LastUse.Value - (tick() - COOLDOWN_TIME))
			if mouse then
				mouse.Icon="rbxasset://textures\\GunCursor.png"
			end
		end
	end)
end

function OnUnequipped()
	CurrentMouse = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)