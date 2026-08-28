local GearService = require(1075123174)

local Tool = script.Parent
local Gear = GearService:BindGear(Tool, "Sword")
Gear.Class:SetSlashDamage(20)
Gear.Class:DisableLunge()

Gear:BindEquippedFunction("ChangeAnimation", function()
	if Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Gear.Class:BindSlashAnimation(Tool.R15Stab)
	else
		Gear.Class:BindSlashAnimation(Tool.Stab)
	end
end)