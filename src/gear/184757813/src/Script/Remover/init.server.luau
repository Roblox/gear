--Made by Luckymaxer

Debris = game:GetService("Debris")

FixCamera = script:WaitForChild("FixCamera")

Creator = script:FindFirstChild("Creator")
Model = script:FindFirstChild("Model")

function DestroyModel()
	if Creator and Creator.Parent then
		local FixCameraClone = FixCamera:Clone()
		FixCameraClone.Disabled = false
		if Character and Character.Parent then
			FixCameraClone.Parent = Character
		else
			local Backpack = Creator:FindFirstChild("Backpack")
			if Backpack then
				FixCameraClone.Parent = Backpack
			end
		end
	end
	Debris:AddItem(script, 2)
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Model or not Model.Value or not Model.Value.Parent then
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

Model.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyModel()
	end
end)