local Tool = script.Parent;
local Torso

Tool.Enabled = true
local sparkles = script.Parent.Handle:findFirstChild("Sparkles")

function onActivated()
	if not Tool.Enabled  then
		return
	end
	
	local RightArm = Tool.Parent:FindFirstChild("RightUpperArm")
	local RightShoulder = Torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")

	sparkles.Enabled = true

	snowglobesound:Play()

	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3
	wait(.2)
	--[[Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	--]]

	RightShoulder.MaxVelocity = 1

	sparkles.Enabled = false
	Tool.Enabled = true

end

function onEquipped()
	snowglobesound = Instance.new("Sound")
	snowglobesound.SoundId = "http://www.roblox.com/asset/?id=19286245" 
	snowglobesound.Parent = Tool
	Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
end

function onUnequipped()
	snowglobesound:Stop()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
