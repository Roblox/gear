--Made by Luckymaxer

Figure = script.Parent

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Creator = Figure:FindFirstChild("Creator")

--Humanoid = Figure:WaitForChild("Humanoid")
Head = Figure:WaitForChild("Head")
Torso = Figure:WaitForChild("Torso")

Neck = Torso:WaitForChild("Neck")
LeftShoulder = Torso:WaitForChild("Left Shoulder")
RightShoulder = Torso:WaitForChild("Right Shoulder")
LeftHip = Torso:WaitForChild("Left Hip")
RightHip = Torso:WaitForChild("Right Hip")

for i, v in pairs({Neck, LeftShoulder, RightShoulder, LeftHip, RightHip}) do
	if v and v.Parent then
		v.MaxVelocity = 0.1
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

Pose = script:WaitForChild("Pose")
Pose.Value = "None"
LastPose = Pose.Value
PoseTime = tick()

function SetPose(pose)
	LastPose = Pose.Value
	Pose.Value = pose
	PoseTime = tick()
end

function OnRunning(Speed)
	if Speed > 0 then
		SetPose("Running")
	else
		SetPose("Standing")
	end
end

function OnDied()
	SetPose("Dead")
end

function OnJumping()
	SetPose("Jumping")
end

function OnClimbing()
	SetPose("Climbing")
end

function OnGettingUp()
	SetPose("GettingUp")
end

function OnFreeFall()
	SetPose("FreeFall")
end

function OnFallingDown()
	SetPose("FallingDown")
end

function OnSeated()
	SetPose("Seated")
end

function OnPlatformStanding()
	SetPose("PlatformStanding")
end

function OnSwimming(Speed)
	return OnRunning(Speed)
end

function MoveJump()
	RightShoulder.MaxVelocity = 0.075
	LeftShoulder.MaxVelocity = 0.075
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function MoveFreeFall()
	RightShoulder.MaxVelocity = 0.125
	LeftShoulder.MaxVelocity = 0.125
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0	
end

function MoveSit()
	RightShoulder.MaxVelocity = 0.075
	LeftShoulder.MaxVelocity = 0.075
	RightShoulder.DesiredAngle = (math.pi / 2)
	LeftShoulder.DesiredAngle = -(math.pi / 2)
	RightHip.DesiredAngle = 1
	LeftHip.DesiredAngle = -1
end

function Move(Time)
	local LimbAmplitude
	local LimbFrequency
	local NeckAmplitude
	local NeckFrequency
	local NeckDesiredAngle
  
	if (Pose.Value == "Jumping") then
		MoveJump()
		return
	elseif (Pose.Value == "FreeFall") then
		MoveFreeFall()
		return
	elseif (Pose.Value == "Seated") then
		MoveSit()
		return
	end

	local ClimbFudge = 0
	
	if (Pose.Value == "Running" or Pose.Value == "Attacking") then
		RightShoulder.MaxVelocity = 0.075
		LeftShoulder.MaxVelocity = 0.075
		LimbAmplitude = 1
		LimbFrequency = 9
		NeckAmplitude = 0
		NeckFrequency = 0
		NeckDesiredAngle = 0
		if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character then
			local CreatorCharacter = Creator.Value.Character
			local CreatorHead = CreatorCharacter:FindFirstChild("Head")
			if CreatorHead then
				local TargetPosition = CreatorHead.Position
				local Direction = Torso.CFrame.lookVector
				local HeadPosition = Head.Position
				NeckDesiredAngle = ((((HeadPosition - TargetPosition).Unit):Cross(Direction)).Y / 4)
			end
		end
	elseif (Pose.Value == "Climbing") then
		RightShoulder.MaxVelocity = 0.5
		LeftShoulder.MaxVelocity = 0.5
		LimbAmplitude = 1
		LimbFrequency = 9
		NeckAmplitude = 0
		NeckFrequency = 0
		NeckDesiredAngle = 0
		ClimbFudge = math.pi
	else
		LimbAmplitude = 0.1
		LimbFrequency = 1
		NeckAmplitude = 0.25
		NeckFrequency = 1.25
	end

	NeckDesiredAngle = ((not NeckDesiredAngle and (NeckAmplitude * math.sin(Time * NeckFrequency))) or NeckDesiredAngle)
	LimbDesiredAngle = (LimbAmplitude * math.sin(Time * LimbFrequency))
	
	Neck.DesiredAngle = NeckDesiredAngle
	RightShoulder.DesiredAngle = (LimbDesiredAngle + ClimbFudge)
	LeftShoulder.DesiredAngle = (LimbDesiredAngle - ClimbFudge)
	if Pose.Value ~= "Attacking" then
		RightHip.DesiredAngle = -LimbDesiredAngle
		LeftHip.DesiredAngle = -LimbDesiredAngle
	else
		RightHip.DesiredAngle = 0
		LeftHip.DesiredAngle = 0
	end
	
	for i, v in pairs({Neck, LeftShoulder, RightShoulder, LeftHip, RightHip}) do
		if not v or not v.Parent or not v.Part0 or not v.Part0.Parent or not v.Part1 or not v.Part1.Parent then
			Debris:AddItem(Figure, 0.5)
		end
	end
	
	
end

--[[Humanoid.Died:connect(OnDied)
Humanoid.Running:connect(OnRunning)
Humanoid.Jumping:connect(OnJumping)
Humanoid.Climbing:connect(OnClimbing)
Humanoid.GettingUp:connect(OnGettingUp)
Humanoid.FreeFalling:connect(OnFreeFall)
Humanoid.FallingDown:connect(OnFallingDown)
Humanoid.Seated:connect(OnSeated)
Humanoid.PlatformStanding:connect(OnPlatformStanding)
Humanoid.Swimming:connect(OnSwimming)

Humanoid:ChangeState(Enum.HumanoidStateType.None)]]

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	Move(Time)
end)