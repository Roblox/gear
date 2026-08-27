--Script to become the Indiana Jones boulder!

local Character = script.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Root = Character:WaitForChild("HumanoidRootPart",10)

local Orb = script:WaitForChild("Orb",10).Value

local Camera = workspace.CurrentCamera

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}



local Moving = false


Services.RunService.RenderStepped:Connect(function()
	if Humanoid.MoveDirection.Magnitude > 0 then
		Orb.Velocity = Orb.Velocity + Humanoid.MoveDirection * 2
	end
end)