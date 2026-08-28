local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle

local Trail = Handle:FindFirstChildOfClass("Trail")

local Gear = GearService:BindGear(Tool, "Sword")

Gear:BindActivateFunction("pot_of_gold_activate", function()
	if Trail then
		Trail.Enabled = true
		delay(0.2, function()
			if Trail then
				Trail.Enabled = false
			end
		end)
	end
end)