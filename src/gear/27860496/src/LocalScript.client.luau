local Tool = script.Parent

local Animations = Tool:WaitForChild("Animations")
local R6Folder = Animations:WaitForChild("R6")
local R15Folder = Animations:WaitForChild("R15")
local ServerControls = Tool:WaitForChild("ServerControls")

function onActivatedLocal()	
	local humanoid = Tool.Parent:FindFirstChild("Humanoid", false)
	local anim = nil

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		anim = humanoid:LoadAnimation(R15Folder:WaitForChild("staffup"))
	else
		anim = humanoid:LoadAnimation(R6Folder:WaitForChild("staffup"))
	end

	anim:Play(0.1,1,1)

	wait(1.5)

	if anim then
		anim:Stop()
		anim:Destroy()
	end

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		anim = humanoid:LoadAnimation(R15Folder:WaitForChild("staffout"))
	else
		anim = humanoid:LoadAnimation(R6Folder:WaitForChild("staffout"))
	end	

	anim.KeyframeReached:connect(function(string)
		if string == "end" then
			wait(0.4)
			if anim then
				anim:Stop()
				anim:Destroy()
			end
		end

	end)
end

ServerControls.OnClientEvent:Connect(onActivatedLocal)