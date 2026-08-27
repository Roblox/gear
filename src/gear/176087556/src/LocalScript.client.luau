--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

ClientControl = Tool:WaitForChild("ClientControl")

Equipped = false

ClientControl.OnClientInvoke = (function(Mode, Value)
	if not Equipped or not Humanoid then
		return
	end
	if Mode == "PlayAnimation" then
		if CurrentAnimation then
			CurrentAnimation:Stop()
		end
		CurrentAnimation = Humanoid:LoadAnimation(Value.Animation)
		if CurrentAnimation then
			CurrentAnimation:Play(nil, nil, Value.Speed)
		end
	elseif Mode == "StopAnimation" then
		if CurrentAnimation then
			CurrentAnimation:Stop()
		end
	end
end)

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	Equipped = false
	if CurrentAnimation then
		CurrentAnimation:Stop()
	end
end

Tool.Unequipped:connect(Unequipped)
Tool.Equipped:connect(Equipped)