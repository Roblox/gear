--Made by Luckymaxer

Tool = script.Parent

Players = game:GetService("Players")

Player = Players.LocalPlayer

Icons = {
	Normal = "rbxasset://textures/GunCursor.png",
	Reloading = "rbxasset://textures/GunWaitCursor.png"
}

ToolEquipped = false

function UpdateIcon()
	if Mouse and ToolEquipped then
		Mouse.Icon = (((Tool.Enabled and (Mouse.Icon == Icons.Reloading or Mouse.Icon == "")) and Icons.Normal) or ((not Tool.Enabled and (Mouse.Icon == Icons.Normal or Mouse.Icon == "")) and Icons.Reloading) or Mouse.Icon)
	end
end

function Equipped()
	ToolEquipped = true
	Mouse = Player:GetMouse()
	MouseChanged = Mouse.Changed:connect(Changed)
	UpdateIcon()
end

function Unequipped()
	ToolEquipped = false
	Mouse.Icon = ""
	if MouseChanged then
		MouseChanged:disconnect()
	end
end

function Changed(Property)
	if Property == "Enabled" or (Property == "Icon" and Mouse.Icon == "") then
		UpdateIcon()
	end
end

Tool.Changed:connect(Changed)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)