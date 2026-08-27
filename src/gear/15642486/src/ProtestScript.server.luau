--Updated for R15 avatars by StarWars
local Tool = script.Parent;

enabled = true

local sounds = {Tool.Handle.AngrySound1, Tool.Handle.AngrySound2, Tool.Handle.AngrySound3}


function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	local Character = Tool.Parent
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightUpperArm")
	local RightShoulder = RightArm:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")

	sounds[math.random(3)]:Play()

	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)

	RightShoulder.MaxVelocity = 1

--[[
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(0,0,2)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
]]--
	enabled = true

end



script.Parent.Activated:connect(onActivated)

