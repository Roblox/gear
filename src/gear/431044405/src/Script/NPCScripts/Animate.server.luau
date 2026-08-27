--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

Creator = Figure:FindFirstChild("Creator")

Humanoid = Figure:WaitForChild("Humanoid")
Head = Figure:WaitForChild("Head")
Torso = Figure:WaitForChild("Torso")

Neck = Torso:WaitForChild("Neck")
LeftShoulder = Torso:WaitForChild("Left Shoulder")
RightShoulder = Torso:WaitForChild("Right Shoulder")
LeftHip = Torso:WaitForChild("Left Hip")
RightHip = Torso:WaitForChild("Right Hip")

for i, v in pairs({Neck, LeftShoulder, RightShoulder, LeftHip, RightHip}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

Pose = "None"
LastPose = Pose
PoseTime = tick()

ToolAnimTime = 0

function SetPose(pose)
	LastPose = Pose
	Pose = pose
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
	Debris:AddItem(Figure, 3)
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
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function MoveFreeFall()
	RightShoulder.MaxVelocity = 0.25
	LeftShoulder.MaxVelocity = 0.25
	RightShoulder.DesiredAngle = math.pi
	LeftShoulder.DesiredAngle = -math.pi
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0	
end

function MoveSit()
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder.DesiredAngle = (math.pi / 2)
	LeftShoulder.DesiredAngle = -(math.pi / 2)
	RightHip.DesiredAngle = 1
	LeftHip.DesiredAngle = -1
end

function GetTool()	
	for i, v in pairs(Figure:GetChildren()) do
		if v:IsA("Tool") then
			return v
		end
	end
end

function GetToolAnim(Tool)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("StringValue") and v.Name == "ToolAnim" then
			return v
		end
	end
	return nil
end

function AnimateTool()
	
	if (ToolAnim == "None") then
		return
	end

	if (ToolAnim == "Slash") then
		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 0
		return
	end

	if (ToolAnim == "Lunge") then
		RightShoulder.MaxVelocity = 0.5
		LeftShoulder.MaxVelocity = 0.5
		RightHip.MaxVelocity = 0.5
		LeftHip.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = (math.pi / 2)
		LeftShoulder.DesiredAngle = 0 
		RightHip.DesiredAngle = (math.pi / 2)
		LeftHip.DesiredAngle = 1
		return
	end
	
end

function Move(Time)
	local LimbAmplitude
	local LimbFrequency
	local NeckAmplitude
	local NeckFrequency
	local NeckDesiredAngle
  
	if (Pose == "Jumping") then
		MoveJump()
		return
	elseif (Pose == "FreeFall") then
		MoveFreeFall()
		return
	elseif (Pose == "Seated") then
		MoveSit()
		return
	end

	local ClimbFudge = 0
	
	if (Pose == "Running") then
		RightShoulder.MaxVelocity = 0.15
		LeftShoulder.MaxVelocity = 0.15
		LimbAmplitude = 1
		LimbFrequency = 9
		NeckAmplitude = 0
		NeckFrequency = 0
		NeckDesiredAngle = 0
		--[[if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character then
			local CreatorCharacter = Creator.Value.Character
			local CreatorHead = CreatorCharacter:FindFirstChild("Head")
			if CreatorHead then
				local TargetPosition = CreatorHead.Position
				local Direction = Torso.CFrame.lookVector
				local HeadPosition = Head.Position
				NeckDesiredAngle = ((((HeadPosition - TargetPosition).Unit):Cross(Direction)).Y / 4)
			end
		end]]
	elseif (Pose == "Climbing") then
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
	
	--Neck.DesiredAngle = NeckDesiredAngle
	RightShoulder.DesiredAngle = (LimbDesiredAngle + ClimbFudge)
	LeftShoulder.DesiredAngle = (LimbDesiredAngle - ClimbFudge)
	RightHip.DesiredAngle = -LimbDesiredAngle
	LeftHip.DesiredAngle = -LimbDesiredAngle
	
	local Tool = GetTool()

	if Tool then
	
		AnimStringValueObject = GetToolAnim(Tool)

		if AnimStringValueObject then
			ToolAnim = AnimStringValueObject.Value
			if AnimStringValueObject and AnimStringValueObject.Parent then
				AnimStringValueObject:Destroy()
			end
			ToolAnimTime = (Time + 0.3)
		end

		if Time > ToolAnimTime then
			ToolAnimTime = 0
			ToolAnim = "None"
		end

		AnimateTool()
		
	else
		ToolAnim = "None"
		ToolAnimTime = 0
	end
	
end

Humanoid.Died:connect(OnDied)
Humanoid.Running:connect(OnRunning)
Humanoid.Jumping:connect(OnJumping)
Humanoid.Climbing:connect(OnClimbing)
Humanoid.GettingUp:connect(OnGettingUp)
Humanoid.FreeFalling:connect(OnFreeFall)
Humanoid.FallingDown:connect(OnFallingDown)
Humanoid.Seated:connect(OnSeated)
Humanoid.PlatformStanding:connect(OnPlatformStanding)
Humanoid.Swimming:connect(OnSwimming)

Humanoid:ChangeState(Enum.HumanoidStateType.None)

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	Move(Time)
end)