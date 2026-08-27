--Made by Luckymaxer

Food = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Food:WaitForChild("Creator")
HitSound = Food:WaitForChild("HitSound")
EatScript = script:WaitForChild("EatScript")
Stuck = false

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

Food.Touched:connect(function(Hit)
	if Hit and Hit.Parent and not Stuck then
		local Character, Humanoid = FindCharacterAncestor(Hit.Parent)
		if ((Character and Character ~= Creator.Value.Character and Humanoid and Humanoid.Health > 0) or not Character) then
			if Hit.Name ~= "Handle" and Hit.Name ~= "Effect" then
				Stuck = true
				local Weld = Instance.new("Weld")
				Weld.Part0 = Hit
				Weld.Part1 = Food
				Weld.C0 = Hit.CFrame:toObjectSpace(Food.CFrame)
				Weld.Parent = Food
				local BodyForce = Food:FindFirstChild("BodyForce")
				if BodyForce then
					BodyForce:Destroy()
				end
				HitSound:Play()
				if Character and Character ~= Creator.Value.Character and Humanoid and Humanoid.Health > 0 and not Humanoid:FindFirstChild(EatScript.Name) then
					local EatScriptClone = EatScript:Clone()
					local creator = Creator:Clone()
					creator.Value = Creator.Value
					creator.Parent = EatScriptClone
					local FoodClone = Instance.new("ObjectValue")
					FoodClone.Name = "Food"
					FoodClone.Value = Food
					FoodClone.Parent = EatScriptClone
					EatScriptClone.Disabled = false
					Debris:AddItem(EatScriptClone, 5)
					EatScriptClone.Parent = Humanoid
				end
				wait(5)
				Food:Destroy()
			end
		end
	end
end)