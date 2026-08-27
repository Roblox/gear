local Tool = script.Parent;

enabled = true

local sounds = {Tool.Handle.AngrySound1, Tool.Handle.AngrySound2, Tool.Handle.AngrySound3}


function onActivated()
	if not enabled  then
		return
	end

	enabled = false



	sounds[math.random(3)]:Play()

	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.5
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3
	wait(.2)

	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1

--[[
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(0,0,2)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
]]--
	enabled = true

end



script.Parent.Activated:connect(onActivated)

