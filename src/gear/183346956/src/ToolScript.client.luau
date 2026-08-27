--Rescripted by Luckymaxer
--Modified by alexnewtron


Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

cannonAnimation = nil;

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")


ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlaySound" and Value then
		Value:Play()
	elseif (Mode == "PlayAnimation") then
		cannonAnimation:Play();
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		ServerControl:InvokeServer(Mode, Value)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	cannonAnimation = Humanoid:LoadAnimation(Tool:WaitForChild("Cannon"));
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("Click", true)
	end)
end

local function Unequipped()
	
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)