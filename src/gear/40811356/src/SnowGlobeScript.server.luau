-- HELLO CURIOUS USER. YES THERE IS SOMETHING SPECIAL ABOUT THIS OBJECT.

local Tool = script.Parent;

Tool.Enabled = true
local sparkles = script.Parent.Handle:findFirstChild("Sparkles")

function onActivated()
	if not Tool.Enabled  then
		return
	end

	sparkles.Enabled = true

	snowglobesound:Play()

	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	--[[Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3
	wait(.2)
	--]]

	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1

	sparkles.Enabled = false
	Tool.Enabled = true

end

function onEquipped()
	snowglobesound = Instance.new("Sound")
	snowglobesound.SoundId = "http://www.roblox.com/asset/?id=19358641" 
	snowglobesound.Parent = Tool
end

function onUnequipped()
	snowglobesound:Stop()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
