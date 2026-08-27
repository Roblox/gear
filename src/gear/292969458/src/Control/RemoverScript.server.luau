--Made by Luckymaxer

Model = script.Parent
Humanoid = Model:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

Creator = Model:FindFirstChild("Creator")
Tool = Model:FindFirstChild("Tool")

function DestroyModel()
	Debris:AddItem(Model, 0.5)
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
	DestroyModel()
end)

if Humanoid then
	Humanoid.Died:connect(function()
		DestroyModel()
	end)
end