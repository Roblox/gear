local Tool = script.Parent
local Juice = Tool.Handle

local vCharacter
local myHumanoid

function onActivated()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	if myHumanoid == nil then 
		return
	end

	juiceAnim = myHumanoid:LoadAnimation(Tool.JuiceAnim)
	if juiceAnim then juiceAnim:Play() end
end

function onUnequipped()
	if juiceAnim then juiceAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped) 
