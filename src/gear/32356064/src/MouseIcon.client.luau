local MOUSE_ICON = 'rbxasset://textures/GunCursor.png'
local RELOADING_ICON = 'rbxasset://textures/GunWaitCursor.png'

local Tool = script.Parent

local Mouse = nil

local function UpdateIcon()
	if Mouse then
		Mouse.Icon = Tool.Enabled and MOUSE_ICON or RELOADING_ICON
	end
end

local function OnEquipped(mouse)
	Mouse = mouse
	UpdateIcon()
end

local function OnChanged(property)
	if property == 'Enabled' then
		UpdateIcon()
	end
end

Tool.Equipped:Connect(OnEquipped)
Tool.Changed:Connect(OnChanged)
