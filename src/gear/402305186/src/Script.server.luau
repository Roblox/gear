--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Module = require(191816425)

Handle.Transparency = 0
Tool.Enabled = true

ToolEquipped = false

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	CarpetData.SpawnCarpet()
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and HumanoidRootPart and HumanoidRootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	CarpetFunctions = Module.GetTable({Key = "NonMagicCarpet", Player = Player})
	CarpetData = CarpetFunctions.GetData({Tool = Tool, Player = Player})
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)