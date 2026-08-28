local GearService = require(1075123174)

local Tool = script.Parent
local Gear = GearService:BindGear(Tool, "Sword")
Gear.Class:SetLungeDamage(20)
Gear.Class:SetSlashDamage(10)
Gear.Class:SetGripOut(Tool.Grip)
Gear:BindEquippedFunction("InsertAnimation", function()
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		local NewAnimation = Instance.new("Animation")
		NewAnimation.AnimationId = "rbxassetid://1088114329"
		Gear.Class:BindLungeAnimation(NewAnimation)
	else
		local NewAnimation = Instance.new("Animation")
		NewAnimation.AnimationId = "rbxassetid://1088118628"
		Gear.Class:BindLungeAnimation(NewAnimation)
	end
end)