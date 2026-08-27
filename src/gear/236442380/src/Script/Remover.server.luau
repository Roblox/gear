--Made by Luckymaxer

Part = script.Parent

Debris = game:GetService("Debris")

Creator = Part:FindFirstChild("Creator")

function DestroyModel()
	Debris:AddItem(Part, 1)
end

if not Creator then
	DestroyModel()
	return
end

Creator = Creator.Value

if not Creator or not Creator:IsA("Player") or not Creator.Parent then
	DestroyModel()
	return
end

Character = Creator.Character
if not Character then
	DestroyModel()
	return
end

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator.Parent then
		DestroyModel()
	end
end)

Character.Changed:connect(function(Property)
	if Property == "Parent" and not Character.Parent then
		DestroyModel()
	end
end)
