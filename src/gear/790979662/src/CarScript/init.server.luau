local RunService = game:GetService("RunService")

local Car = require(script:WaitForChild("Car"))

local Model = script.Parent
local Creator = Model:WaitForChild("creator")
local Character = Creator.Value.Character
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local NewCar = Car.new(Creator.Value, Model)

while Creator.Value and Character and Humanoid and Humanoid.Health > 0 do
	local Torso = Character:FindFirstChild("HumanoidRootPart")
	if Torso and Humanoid and Humanoid.Health > 0 then
		local Delta = RunService.Heartbeat:wait()
		NewCar:Update(Delta)
	else
		break
	end
end

Model:Destroy()