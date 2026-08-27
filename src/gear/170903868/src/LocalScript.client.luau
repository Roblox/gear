--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

LocalControls = Tool:WaitForChild("LocalControls")

LocalControls.OnClientInvoke = (function(Player)
	return ((Humanoid and Humanoid.TargetPoint) or nil)
end)

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

Tool.Equipped:connect(Equipped)