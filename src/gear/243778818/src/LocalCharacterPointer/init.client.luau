--[[
	By ArceusInator
--]]
local RenderStepped = game:GetService'RunService'.RenderStepped
local Mouse = game:GetService'Players'.LocalPlayer:GetMouse()

local PointingGyro = nil

RenderStepped:connect(function()
	if PointingGyro and PointingGyro.Parent then
		PointingGyro.cframe = CFrame.new(PointingGyro.Parent.Position, Mouse.Hit.p)
	end
end)

script:WaitForChild'StartPointing'.OnClientEvent:connect(function(gyro)
	PointingGyro = gyro
end)
script:WaitForChild'StopPointing'.OnClientEvent:connect(function()
	PointingGyro = nil
end)