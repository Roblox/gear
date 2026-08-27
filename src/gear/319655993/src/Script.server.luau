--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Module = require(191816425)

ToolEquipped = false

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Data = Module.GetTable({Key = "Boombox", Player = Player, Tool = Tool})
	if not Data then
		return
	end
	Functions = Data.GetData({Player = Player, Tool = Tool})
	if not Functions then
		return
	end
	Functions.SetUpBoombox()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)