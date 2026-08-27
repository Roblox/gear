--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Equipped = false
MouseDown = false

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")


ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "SetTargetFilter" and Value then
		TargetFilter = Value
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		ServerControl:InvokeServer(Mode, Value)
	end)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		if MouseDown then
			return
		end
		MouseDown = true
		Spawn(function()
			while MouseDown do
				InvokeServer("Click", {Down = true, Mouse = {Hit = Mouse.Hit.p}})
				Mouse.TargetFilter = TargetFilter
				wait(0.01)
			end
		end)
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function Unequipped()
	Equipped = false
	MouseDown = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)