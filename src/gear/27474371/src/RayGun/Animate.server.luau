local debris = game:GetService("Debris")
local jumpCoolDown = 0

local Figure = script.Parent

local Torso = Figure:WaitForChild("Torso")
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local RightHip = Torso:WaitForChild("Right Hip")
local LeftHip = Torso:WaitForChild("Left Hip")
local Neck = Torso:WaitForChild("Neck")
local Humanoid = Figure:WaitForChild("Humanoid")

local pose = "Standing"
local toolAnim = "None"
local toolAnimTime = 0
local isSeated = false

function onRunning(speed)
	if isSeated then
		return
	end
	if speed > 0 then
		pose = "Running"
	else
		pose = "Standing"
	end
end

function onDied()
	pose = "Dead"
end

function onJumping()
	isSeated = false
	pose = "Jumping"
end

function onClimbing()
	pose = "Climbing"
end

function onGettingUp()
	pose = "GettingUp"
end

function onFreeFall()
	pose = "FreeFall"
end

function onFallingDown()
	pose = "FallingDown"
end

function onSeated()
	isSeated = true
	pose = "Seated"
end

function moveJump()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function moveFreeFall()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function moveSit()
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder.DesiredAngle = math.pi /2
	LeftShoulder.DesiredAngle = -math.pi /2
	RightHip.DesiredAngle = math.pi /2
	LeftHip.DesiredAngle = -math.pi /2
end

function getTool()
	kidTable = Figure:children()
	if (kidTable ~= nil) then
		numKids = #kidTable
		for i=1,numKids do
			if (kidTable[i].className == "Tool") then
				return kidTable[i]
			end
		end
	end
	return nil
end

function getToolAnim(tool)
	c = tool:children()
	for i=1,#c do
		if (c[i].Name == "toolanim" and c[i].className == "StringValue") then
			return c[i]
		end
	end
	return nil
end

function animateTool()
	if (toolAnim == "None") then
		RightShoulder.DesiredAngle = (math.pi / 2)
		return
	end
	if (toolAnim == "Slash") then
		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 0
		return
	end
	if (toolAnim == "Lunge") then
		RightShoulder.MaxVelocity = 0.5
		LeftShoulder.MaxVelocity = 0.5
		RightHip.MaxVelocity = 0.5
		LeftHip.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = (math.pi / 2)
		LeftShoulder.DesiredAngle = 1.0
		RightHip.DesiredAngle = (math.pi / 2)
		LeftHip.DesiredAngle = 1.0
		return
	end
end

 function move(time)
	local amplitude
	local frequency
	if (pose == "Jumping") then
		moveJump()
		return
	end
	if (pose == "FreeFall") then
		moveFreeFall()
		return
	end
	if (pose == "Seated") then
		moveSit()
		return
	end
	local climbFudge = 0
	if (pose == "Running") then
		RightShoulder.MaxVelocity = 0.15
		LeftShoulder.MaxVelocity = 0.15
		amplitude = 1
		frequency = 9
	elseif (pose == "Climbing") then
		RightShoulder.MaxVelocity = 0.5 
		LeftShoulder.MaxVelocity = 0.5
		amplitude = 1
		frequency = 9
		climbFudge = math.pi
	else
		amplitude = 0.1
		frequency = 1
	end 
	desiredAngle = amplitude * math.sin(time*frequency) 
	RightShoulder.DesiredAngle = desiredAngle + climbFudge
	LeftShoulder.DesiredAngle = desiredAngle - climbFudge
	RightHip.DesiredAngle = -desiredAngle
	LeftHip.DesiredAngle = -desiredAngle
	local tool = getTool()
	if tool ~= nil then
		animStringValueObject = getToolAnim(tool)
		if animStringValueObject ~= nil then
			toolAnim = animStringValueObject.Value
			-- message recieved, delete StringValue
			animStringValueObject.Parent = nil
			toolAnimTime = time + .3
		end
		if time > toolAnimTime then
			toolAnimTime = 0
			toolAnim = "None"
		end
		animateTool()
	else
		toolAnim = "None"
		toolAnimTime = 0
	end
end

-- connect events
Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)

 -- main program
local nextTime = 0
local runService = game:service("RunService");
Humanoid.Health = Humanoid.MaxHealth
PersonToPester = Figure:FindFirstChild("PersonToPester")
while Figure.Parent~=nil do
	time = runService.Stepped:wait()
	if time > nextTime then
		move(time)
		nextTime = time + 0.1
		if Humanoid.Health <= 0 then
			wait(4)
			Humanoid.Parent:remove()
		end
		if not PersonToPester.Value or not PersonToPester.Value:FindFirstChild("Torso") then
			Humanoid:MoveTo(Vector3.new(Humanoid.Parent.Torso.Position.x + math.random(-20,20),Humanoid.Parent.Torso.Position.y,Humanoid.Parent.Torso.Position.z + math.random(-10,10)) , Humanoid.Parent.Torso)
			wait(1)
		else
			if PersonToPester.Value then
				local torso = PersonToPester.Value:FindFirstChild("Torso")
				if torso then
					Humanoid:MoveTo(torso.Position,Humanoid.Parent.Torso)		
					if torso.Position.y > Torso.Position.y + 3 and jumpCoolDown <= 0 then
						local force = Instance.new("BodyForce")
						force.force = Vector3.new(0,20000,0)
						force.Parent = Torso
						debris:AddItem(force,0.05)
						Humanoid.Jump = true
						jumpCoolDown = 10
					end
				end
			end
		end
		if jumpCoolDown > 0 then
			jumpCoolDown = jumpCoolDown - 1
		end
	end
end