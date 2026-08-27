--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Head then
		return
	end
	Head.Anchored = true
	ForceSit = Humanoid.Changed:connect(function(Property)
		if Property == "Sit" and not Humanoid[Property] then
			Humanoid[Property] = true
		end
	end)
	Humanoid.Sit = true
end

function Unequipped()
	if ForceSit then
		ForceSit:disconnect()
	end
	if Humanoid and Humanoid.Parent then
		Humanoid.Sit = false
	end
	if Head and Head.Parent then
		Head.Anchored = false
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)