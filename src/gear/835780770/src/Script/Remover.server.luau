--Made by Luckymaxer

Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")
Model = script:WaitForChild("Model")

function DestroyModel()
	if Model and Model.Parent then
		Debris:AddItem(Model, 1)
		if Model and Model.Parent then
			Model:Destroy()
		end
	end
	Debris:AddItem(script, 1)
	if script and script.Parent then
		script:Destroy()
	end
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Model or not Model.Value then
	DestroyModel()
	return
end

Creator = Creator.Value
Model = Model.Value

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

Model:GetPropertyChangedSignal("Parent"):Connect(function()
	if not Model.Parent then
		DestroyModel()
	end
end)