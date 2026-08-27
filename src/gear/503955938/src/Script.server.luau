--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Module = require(191816425)

Handle.Transparency = 0
Tool.Enabled = true

ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and HumanoidRootPart and HumanoidRootPart.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Functions = Module.GetTable({Key = "DeluxeExplodingLabTable", Player = Player})
	Data = Functions.GetData({Tool = Tool, Player = Player})
	Data.SpawnLabTable()
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" or Property == "Enabled" then
		Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)