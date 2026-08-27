local Tool = script.Parent;

Tool.Enabled = true

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	Tool.Handle.snowglobesound:Play()

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

	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1

	Tool.Enabled = true

end

function onUnequipped()

	Tool.Handle.snowglobesound:Stop()

end

script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequipped)
