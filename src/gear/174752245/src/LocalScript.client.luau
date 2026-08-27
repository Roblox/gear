--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Reload = Tool:WaitForChild("Reload")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" and Humanoid and Humanoid.Health > 0 then
		ReloadAnim = Humanoid:LoadAnimation(Reload)
		if ReloadAnim then
			ReloadAnim:Play()
		end
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
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("Fire", Mouse.Hit.p)
	end)
end

function Unequipped()
	if ReloadAnim then
		ReloadAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)