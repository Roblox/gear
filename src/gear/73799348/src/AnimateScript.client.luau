local Tool = script.Parent
local Axe = Tool.Handle

local slashAnim
local twoHandAnim
local vCharacter

function onActivated()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	if myHumanoid == nil then 
		return
	end

	slashAnim = myHumanoid:LoadAnimation(Tool.AxeSlash)
	
	if slashAnim then slashAnim:Play() end	
	
end

function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then
		twoHandAnim = myHumanoid:LoadAnimation(Tool.TwoHandAnim)
			if twoHandAnim then twoHandAnim:Play() end
	end
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
	if twoHandAnim then twoHandAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)