--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

WatchModule = require(191816425)

ToolEquipped = false

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	WatchFunctions.ActivateDisguise()
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	WatchData = WatchModule.GetTable({Key = "DisguiseWatch", Player = Player})
	if not WatchData then
		return
	end
	WatchFunctions = WatchData.GetData({Player = Player, Tool = Tool, Character = Character})
	if not WatchFunctions then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)