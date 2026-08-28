-- // Created by StarWars
local RunService = game:GetService("RunService")

local tool = script.Parent

local floatingSword

tool.Equipped:Connect(function()
	floatingSword = tool.Parent:WaitForChild("FloatingSword")
end)

tool.Unequipped:Connect(function()
	floatingSword = nil
end)

RunService.RenderStepped:Connect(function()
	if floatingSword then
		local bodyPosition = floatingSword:FindFirstChildOfClass("BodyPosition")
		local bodyGyro = floatingSword:FindFirstChildOfClass("BodyGyro")
		local bodyForce = floatingSword:FindFirstChildOfClass("BodyForce")
		
		if bodyPosition and bodyGyro and bodyForce and tool.Parent and tool.Parent:FindFirstChild("HumanoidRootPart") then
			bodyPosition.Position = (tool.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(0, math.rad(90), 0)).p
			bodyGyro.CFrame = tool.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(0, math.rad(90), 0)
		end
	end
end)