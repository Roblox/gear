local Velo,Gyro = script:WaitForChild("Velo",1),script:WaitForChild("Gyro",1)

if not Velo or not Gyro then return end

local Services = {
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}

local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local Center = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

if not Humanoid or not Center then return end


Velo = Velo.Value
Gyro = Gyro.Value


Services.RunService.RenderStepped:Connect(function()
	if Humanoid and Gyro and Velo and Camera then
		local Final_Direction = Vector3.new(Humanoid.MoveDirection.X,Camera.CFrame.LookVector.Y,Humanoid.MoveDirection.Z)
		--print(Final_Direction:Dot(Camera.CFrame.LookVector))
		if Humanoid.MoveDirection.Magnitude > 0 then
			Velo.Velocity = Camera.CFrame.LookVector * 50 * math.sign(Final_Direction:Dot(Camera.CFrame.LookVector))
		else
			Velo.Velocity = Camera.CFrame.LookVector * 0 * math.sign(Final_Direction:Dot(Camera.CFrame.LookVector))
		end
		Gyro.CFrame = Camera.CFrame
	end
end)