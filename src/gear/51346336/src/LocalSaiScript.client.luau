local Tool = script.Parent
local Sai = Tool.Handle

local dualAnim 

local vCharacter

function onActivatedLocal()
	vCharacter = Tool.Parent
	
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then
		return
	end

	dualAnim = myHumanoid:LoadAnimation(Tool.SaiSlash)
	if dualAnim then dualAnim:Play() end
	while Tool.Enabled == false do wait() end
end

function onEquippedLocal()
end

function onUnequippedLocal()
	if dualAnim then dualAnim:Stop() end
end

Tool.Activated:connect(onActivatedLocal)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
