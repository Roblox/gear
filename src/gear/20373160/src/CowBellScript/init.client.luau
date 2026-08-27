--Modified by EC2
--Updated by StarWars for R15 avatars

local Tool = script.Parent;
local Handle = Tool.Handle;
local Humanoid

local Animations = {
	Ring = Tool:WaitForChild("Ring");
	R15Ring = Tool:WaitForChild("R15Ring");
}

Debris = game:GetService("Debris")
OcowBell = script:WaitForChild("Sound")
Tool.Enabled = true

local RingAnimation = nil

function onActivated()
	if not Tool.Enabled then
		return
	end
	cowBell = OcowBell:clone()
	Debris:AddItem(cowBell, 2)
	cowBell.Parent = Handle
	cowBell:Play()
	if RingAnimation then
	RingAnimation:Play()
	wait(.4)
	RingAnimation:Play()
	end
end

function onEquipped()
	Humanoid = Tool.Parent.Humanoid
	
	
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			RingAnimation = Humanoid:LoadAnimation(Animations["R15Ring"])
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			RingAnimation = Humanoid:LoadAnimation(Animations["Ring"])
		end
	end
	
	if RingAnimation then
		RingAnimation:Play()
	end
end

function onUnequipped()
	cowBell:Stop()
	if RingAnimation then
		RingAnimation:Stop()
	end	
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
