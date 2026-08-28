local Tool = script.Parent

local MouseInput = Tool:WaitForChild("MousePos",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid



function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end

end

function Unequipped()
	
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

function MouseInput.OnClientInvoke()
	return (Humanoid and Humanoid.TargetPoint) or Vector3.new(0,0,0)--game.Players.LocalPlayer:GetMouse().Hit.p
end