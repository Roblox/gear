local Tool = script.Parent

-- Animations
local staffAnim

local Animations = {
	ForceStaff = Tool:WaitForChild("ForceStaffAnim");
	R15ForceStaff = Tool:WaitForChild("R15ForceStaffAnim")
}

function onActivatedL()
	vCharacter = Tool.Parent

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	if Tool.Enabled then
		if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
			staffAnim = myHumanoid:LoadAnimation(Animations.R15ForceStaff)
		else
			staffAnim = myHumanoid:LoadAnimation(Animations.ForceStaff)
		end
		staffAnim:Play()	
	end
end

function onEquippedL()
end

function onUnequippedL()
	if staffAnim then staffAnim:Stop() end	
end

Tool.Activated:connect(onActivatedL)
Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)