-- // Created by StarWars
local RunService = game:GetService("RunService")

local tool = script.Parent
local wandMotorsFolder = tool:WaitForChild("WandMotors")

local count = 0

local SPEED = 10

RunService.Stepped:Connect(function(_, step)
	for _, motor in pairs(wandMotorsFolder:GetChildren()) do
		if motor:IsA("Motor6D") then
			motor.Transform = motor.Transform * CFrame.Angles(0, 0, math.rad(count))
		end
	end
	count = (count + (step * SPEED)) % 360
end)