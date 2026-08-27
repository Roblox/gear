--Updated for R15 avatars by StarWars
local Tool = script.Parent;

enabled = true

local ghostChar = nil

function makeMeGhostly(trans)


	if ghostChar == nil then return end
	local parts = {"Head", "Torso", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "UpperTorso", "LowerTorso", "RightUpperArm", "RightLowerArm",
		"RightHand", "LeftHand", "LeftLowerArm", "LeftUpperArm", "LeftLowerLeg", "LeftUpperLeg", "RightLowerLeg", "RightUpperLeg",
		"RightFoot", "LeftFoot"}

	for i=1,#parts do
		local p = ghostChar:FindFirstChild(parts[i])
		if p ~= nil then p.Transparency = trans end
	end

	
end

function UpdateGhostState(isUnequipping)

	if isUnequipping == true then
		makeMeGhostly(0)
		ghostChar = nil
	else
		ghostChar = Tool.Parent
		makeMeGhostly(.5)
	end
	

end

function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-.981, .196, 0)
	Tool.GripPos = Vector3.new(-.5, -0.6, -1.5)
	Tool.GripRight = Vector3.new(0, -0, -1)
	Tool.GripUp = Vector3.new(0.196, .981, 0)


	Tool.Handle.DrinkSound:Play()

	wait(.8)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		UpdateGhostState(false)
	end

	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(-.5, -.1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(0,1,0)


	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)



function onUnequipped()
	UpdateGhostState(true)
end



script.Parent.Unequipped:connect(onUnequipped)
