--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

ClientControl = Tool:WaitForChild("ClientControl")
ServerControl = Tool:WaitForChild("ServerControl")

function Click(Down)
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	pcall(function()
		ClientControl:InvokeServer("Click", Down)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		Click(true)
	end)
end

function Unequipped()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)