-- // Created by StarWars
local tool = script.Parent

local MOUSE_ICON = "rbxasset://textures/GunCursor.png"
local RELOADING_ICON = "rbxasset://textures/GunWaitCursor.png"

local mouse

function UpdateIcon()
	if mouse then
		mouse.Icon = tool.Enabled and MOUSE_ICON or RELOADING_ICON
	end
end

tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)
tool.Equipped:Connect(function(toolMouse)
	mouse = toolMouse
	UpdateIcon()
end)