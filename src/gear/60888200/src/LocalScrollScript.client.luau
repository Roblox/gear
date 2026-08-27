local Tool = script.Parent
local Scroll = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid

local scrollAnim 

Tool.Enabled = true

local scrollSummon

function onActivated()
	if Tool.Enabled == false then 
		return 
	end	
	
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return 	
	end

	Tool.Enabled = false 

	scrollSummon = Tool:FindFirstChild("ScrollSummon")
	if scrollSummon then 
		if scrollSummon.Value == 1 then 
			return 
		else
			scrollSummon.Value = 1
		end
	end 		
	
	scrollAnim = myHumanoid:LoadAnimation(Tool.ScrollAnim)
	if scrollAnim then scrollAnim:Play() end

	Scroll.Transparency = 1.0

	wait(5.0)
	Scroll.Transparency = 0.0
	Tool.Enabled = true
end 

function onUnequipped()
	if scrollAnim then scrollAnim:Stop() end
	Scroll.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
