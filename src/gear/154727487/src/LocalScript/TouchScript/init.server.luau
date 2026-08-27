--Made by Luckymaxer

Part = script.Parent
Creator = Part:WaitForChild("Creator")
Player = Creator.Value
Character = Player.Character

SlimeScript = script:WaitForChild("SlimeScript")

Debounce = false

TouchConnection = nil

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

TouchConnection = Part.Touched:connect(function(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit)
		if character and character ~= Character and not character:FindFirstChild("ForceField") and humanoid and humanoid.Health > 0 and not humanoid:FindFirstChild(SlimeScript.Name) and not Debounce then
			Debounce = true
			local SlimeScriptClone = SlimeScript:Clone()
			local creator = Creator:Clone()
			creator.Value = Creator.Value
			creator.Parent = SlimeScriptClone
			SlimeScriptClone.Disabled = false
			SlimeScriptClone.Parent = humanoid
			TouchConnection:disconnect()
		end
	end
end)

wait(3)

TouchConnection:disconnect()