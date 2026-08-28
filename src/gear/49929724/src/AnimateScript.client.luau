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

	if myHumanoid then
		if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
			slashAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("R15AxeSlash"))
		else 
			slashAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("AxeSlash"))
		end 
	end 
	
	if slashAnim then slashAnim:Play() end	
	
end

function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then
		if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
			twoHandAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("R15TwoHandAnim"))
		else 
			twoHandAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("TwoHandAnim"))
		end 
		if twoHandAnim then twoHandAnim:Play() end
	end
end

function onUnequipped()
	if slashAnim then 
		slashAnim:Stop() 
		slashAnim:Destroy()
	end
	if twoHandAnim then 
		twoHandAnim:Stop() 
		twoHandAnim:Destroy()
	end

	slashAnim = nil
	twoHandAnim = nil
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)