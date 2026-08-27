--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if player == Player and CheckIfAlive() then
	end
end)

function InvokeServer(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ServerControl:InvokeServer(Mode, Value)
	end)
	return ReturnValue
end

function CheckIfAlive()
	return (Character and Character.Parent and Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true, Target = Mouse.Target})
	end)
end

function Unequipped()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)