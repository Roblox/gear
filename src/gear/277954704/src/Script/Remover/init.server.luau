--Made by Luckymaxer

Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")
Tool = script:FindFirstChild("Tool")
Model = script:WaitForChild("Model")

FixClient = script:WaitForChild("FixClient")

function DestroyModel()
	if Model and Model.Parent then
		Debris:AddItem(Model, 2)
	end
	if Creator and Creator.Parent and Creator:IsA("Player") then
		local PlayerGui = Creator:FindFirstChild("PlayerGui")
		if PlayerGui then
			local FixClientClone = FixClient:Clone()
			FixClient.Disabled = false
			Debris:AddItem(FixClient, 2)
			FixClient.Parent = PlayerGui
		end
	end
	Debris:AddItem(script, 2)
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Tool or not Tool.Value or not Tool.Value.Parent or not Model or not Model.Value then
	DestroyModel()
	return
end

Creator = Creator.Value
Tool = Tool.Value
Model = Model.Value

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

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyModel()
	end
end)

Model.Changed:connect(function(Property)
	if Property == "Parent" and not Model.Parent then
		DestroyModel()
	end
end)