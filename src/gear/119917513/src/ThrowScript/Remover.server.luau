--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

Creator = Model:FindFirstChild("Creator")
Remove = Model:FindFirstChild("Remove")

function DestroyModel(Duration)
	Debris:AddItem(Model, ((not Duration and 2) or Duration))
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Remove then
	DestroyModel()
	return
end

Creator = Creator.Value

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator.Parent then
		DestroyModel()
	end
end)

Remove.Changed:connect(function()
	if Remove.Value then
		Model:BreakJoints()
		DestroyModel(10)
	end
end)