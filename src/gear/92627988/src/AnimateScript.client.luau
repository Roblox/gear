local Tool = script.Parent
local Axe = Tool.Handle

local slamAnim
local vCharacter

function onActivated()
	vCharacter = Tool.Parent
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	if not myHumanoid then 
		return
	end

	if myHumanoid then
		if myHumanoid.RigType == Enum.HumanoidRigType.R15 then
			slamAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("R15ClubSlam"))
		else 
			slamAnim = myHumanoid:LoadAnimation(Tool.ClubSlam)
		end 
	end 

	if slamAnim then 
		slamAnim:Play() 
	end	
end

function onEquipped()
end


function onUnequipped()
	if slamAnim then 
		slamAnim:Stop() 
		slamAnim:Destroy()
	end

	slamAnim = nil
end

Tool.Activated:Connect(onActivated)
Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
