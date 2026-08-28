local Tool = script.Parent

-- Animations
local wandAnim

function onActivatedL()
	vCharacter = Tool.Parent

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	if Tool.Enabled then
		wandAnim = myHumanoid:LoadAnimation(Tool.WandAnim)
		if wandAnim then wandAnim:Play() end
	end
end

function onEquippedL()
end

function onUnequippedL()
	if wandAnim then wandAnim:Stop() end
end

Tool.Activated:connect(onActivatedL)
Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)