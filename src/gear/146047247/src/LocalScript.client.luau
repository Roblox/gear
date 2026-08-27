local ContentProvider = game:GetService("ContentProvider")

Mouse_Icon = "rbxasset://textures/GunCursor.png"
Reloading_Icon = "rbxasset://textures/GunWaitCursor.png"

Tool = script.Parent

local Event = Tool:WaitForChild("Event")

local Assets = {"rbxassetid://145815814", "rbxassetid://145815862"}

local MOUSE_DOWN = 0
local MOUSE_UP = 1

Mouse = nil

local Equipped = false

ContentProvider:PreloadAsync(Assets)

function UpdateIcon()
	if not Equipped then return end
	if Mouse then
		Mouse.Icon = Tool.Enabled and Mouse_Icon or Reloading_Icon
	end
end

function OnEquipped(ToolMouse)
	Equipped = true
	Mouse = ToolMouse
	Mouse.Button1Down:Connect(function()
		Event:FireServer(MOUSE_DOWN)
	end)
	
	Mouse.Button1Up:Connect(function()
		Event:FireServer(MOUSE_UP)
	end)
	UpdateIcon()
end

function OnUnequipped()
	Equipped = false
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)
