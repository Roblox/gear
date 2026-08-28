local Tool = script.Parent

-- Animations
local staffAnim

function onActivatedL()
	vCharacter = Tool.Parent

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	if Tool.Enabled then
		staffAnim = myHumanoid:LoadAnimation(Tool.LightStaffAnim)
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