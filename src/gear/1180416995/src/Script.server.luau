-- // Created by StarWars
local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Gear = GearService:BindGear(Tool, "Sword")
Gear:SetupLocalScript("MouseIcon")
Gear.Class:SetLungeDamage(20)
Gear.Class:SetSlashDamage(10)

local LastClick = 0 
Gear:BindActivateFunction("trail_effect", function()

	if tick() - LastClick > 1 then
		LastClick = tick()
		local Trail = Gear.Tool.Handle:FindFirstChildOfClass("Trail")
		if Trail then
			Trail.Enabled = true
			delay(0.5, function()
				if Trail then
					Trail.Enabled = false
				end
			end)
		end
	end
end)