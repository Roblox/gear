Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

MultiModule = require(191816425)

ToolEquipped = false

Remotes = Tool:FindFirstChild("Remotes")
ServerControl = Remotes:FindFirstChild("ServerControl")
ClientControl = Remotes:FindFirstChild("ClientControl")
ReloadTime = 8

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or not SnakeFunctions then
		return
	end
	Tool.Handle.Transparency = 1
	wait(1)
	local MousePos = MouseData.Position
	Tool.Enabled = false
	SnakeFunctions.SummonSnakes(MousePos)
	wait(ReloadTime)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	SnakeData = MultiModule.GetTable({Key = "AttackSnakes", Player = Player, Tool = Tool})
	if not SnakeData then
		return
	end
	SnakeFunctions = SnakeData.GetData({Player = Player, Tool = Tool})
	if not SnakeFunctions then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)