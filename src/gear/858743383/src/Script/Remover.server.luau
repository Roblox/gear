Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Model:FindFirstChild("Creator")
Tool = Model:FindFirstChild("Tool")

function DestroyModel()
	Debris:AddItem(Model, 2)
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Tool or not Tool.Value or not Tool.Value.Parent then
	DestroyModel()
	return
end

Creator = Creator.Value
Tool = Tool.Value

Character = Creator.Character
if not Character then
	DestroyModel()
	return
end

Creator:GetPropertyChangedSignal("Parent"):Connect(function()
	if not Creator.Parent then
		DestroyModel()
	end
end)

Character:GetPropertyChangedSignal("Parent"):Connect(function()
	if not Character.Parent then
		DestroyModel()
	end
end)

Tool:GetPropertyChangedSignal("Parent"):Connect(function()
	if (not Tool.Parent or (not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent))) then
		DestroyModel()
	end
end)