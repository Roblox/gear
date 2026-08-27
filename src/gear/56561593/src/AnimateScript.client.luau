local Tool = script.Parent
local Potion = Tool.Handle

local vCharacter
local myHumanoid

local potionAnim

function onActivated()		
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")
	if myHumanoid == nil then 
		return
	end
	if myHumanoid then
		if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
			potionAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("R15PotionAnim"))
		else 
			potionAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("PotionAnim"))
		end
	end 
	
	if potionAnim then potionAnim:Play() end
end

function onEquipped(mouse)	
	vCharacter = Tool.Parent	
end

function onUnequipped()	
	if potionAnim then 
		potionAnim:Stop()
		potionAnim:Destroy() 
	end

	potionAnim = nil
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)


