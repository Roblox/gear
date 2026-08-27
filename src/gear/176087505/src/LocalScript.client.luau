--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Equipped = false

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if not Equipped then
		return
	end
	if Mode == "PlayAnimation" then
		if AnimPlaying then
			AnimPlaying:Stop()
		end
		AnimPlaying = Humanoid:LoadAnimation(Value.Animation)
		if AnimPlaying then
			AnimPlaying:Play(nil, nil, Value.Speed)
		end
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
		InvokeServer("Click", true)
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
end

function Unequipped()
	Equipped = false
	if AnimPlaying then
		AnimPlaying:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)