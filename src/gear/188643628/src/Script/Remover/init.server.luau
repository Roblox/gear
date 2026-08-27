--Made by Luckymaxer

Model = script

Debris = game:GetService("Debris")

FixCamera = script:FindFirstChild("FixCamera")

Creator = Model:FindFirstChild("Creator")
Tool = Model:FindFirstChild("Tool")

function DestroyModel()
	Debris:AddItem(Model, 2)
	if Creator and Creator.Parent then
		local Backpack = Creator:FindFirstChild("Backpack")
		local FixCameraClone = FixCamera:Clone()
		FixCameraClone.Disabled = false
		FixCameraClone.Parent = ((Backpack and Backpack) or Character)
	end
end

if not FixCamera or not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Tool or not Tool.Value or not Tool.Value.Parent then
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
	if Property == "Parent" and Tool.Parent ~= Character then
		DestroyModel()
	end
end)