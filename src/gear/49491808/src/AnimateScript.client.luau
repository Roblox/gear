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
		if myHumanoid then
			if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
				staffAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("R15FireStaffAnim"))
			else 
				staffAnim = myHumanoid:LoadAnimation(Tool.FireStaffAnim)
			end 
			staffAnim:Play()	
		end 
	end
end
function onUnequippedL()
	if staffAnim then 
		staffAnim:Stop() 
		staffAnim:Destroy()
	end	

	staffAnim = nil
end

Tool.Activated:connect(onActivatedL)
Tool.Unequipped:connect(onUnequippedL)