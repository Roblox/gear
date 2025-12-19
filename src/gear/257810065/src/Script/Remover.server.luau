--Made by Luckymaxer

Model = script.Parent
Humanoid = Model:FindFirstChild("Humanoid")

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
		local Player = ((Tool.Parent and ((Tool.Parent:IsA("Backpack") and Tool.Parent.Parent) or Players:GetPlayerFromCharacter(Tool.Parent))) or nil)
		if (not Player or (Player and Player ~= Creator)) then
			DestroyModel()
		end
	end
end)

if Humanoid then
	Humanoid.Died:connect(function()
		DestroyModel()
	end)
end