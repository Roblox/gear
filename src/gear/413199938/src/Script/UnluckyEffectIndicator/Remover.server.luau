--Made by Luckymaxer

Gui = script.Parent

Debris = game:GetService("Debris")

Creator = Gui:WaitForChild("Creator")

function RemoveGui()
	Gui.Enabled = false
	Debris:AddItem(Gui, 1)
end

if not Creator or not Creator.Value or not Creator.Value.Parent then
	RemoveGui()
	return
end

Creator = Creator.Value

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator.Parent or not Creator.Parent.Parent then
		RemoveGui()
		return
	end
end)
