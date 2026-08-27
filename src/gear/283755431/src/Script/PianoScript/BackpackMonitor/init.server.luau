--Made by Luckymaxer

Creator = script:WaitForChild("Creator")
Model = script:WaitForChild("Model")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BackpackEnabler = script:WaitForChild("BackpackEnabler")

function EnableBackpack()
	if Creator.Parent then
		for i, v in pairs({Creator.Character, Creator:FindFirstChild("Backpack"), Creator:FindFirstChild("PlayerGui")}) do
			if v and v.Parent then
				local BackpackEnablerCopy = BackpackEnabler:Clone()
				BackpackEnablerCopy.Disabled = false
				BackpackEnablerCopy.Parent = v
			end
		end
	end
	Debris:AddItem(script, 1)
end

if Creator.Value and Creator.Value:IsA("Player") then
	Creator = Creator.Value
	Creator.Changed:connect(function(Property)
		if Property == "Parent" or Property == "Character" then
			EnableBackpack()
		end
	end)
end

if Model.Value then
	Model = Model.Value
	Model.Changed:connect(function(Property)
		if Property == "Parent" and not Model.Parent then
			EnableBackpack()
		end
	end)
end