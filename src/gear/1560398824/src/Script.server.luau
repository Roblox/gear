local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
local BladeMotor = Handle:FindFirstChild("Blade")

local Gear = GearService:BindGear(Tool, "Sword")

Gear:BindActivateFunction("pizza_slider_swing", function()
	if BladeMotor then
		BladeMotor.DesiredAngle = BladeMotor.DesiredAngle - math.pi
	end
end)