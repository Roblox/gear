--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlaySound" and Value then
		Value:Play()
	end
end)

function InvokeServer(Mode, Value, arg)
	pcall(function()
		ServerControl:InvokeServer(Mode, Value, arg)
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
		InvokeServer("Click", true, Mouse.Hit.p)
	end)
end

local function Unequipped()
	
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)