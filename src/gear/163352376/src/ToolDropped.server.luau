--Made by Luckymaxer

Tool = script.Parent

Players = game:GetService("Players")

CurrentUFO = Tool:WaitForChild("CurrentUFO")

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		local Player = Players:GetPlayerFromCharacter(Tool.Parent)
		if not Tool.Parent:IsA("Backpack") and not Player and CurrentUFO and CurrentUFO.Value and CurrentUFO.Value.Parent then
			CurrentUFO.Value:Destroy()
		end
	end
end)