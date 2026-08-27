--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")

Shell = Figure:WaitForChild("Shell")
LeftShoulder = Shell:WaitForChild("TopLeftFin")
RightShoulder = Shell:WaitForChild("TopRightFin")
LeftHip = Shell:WaitForChild("BottomLeftFin")
RightHip = Shell:WaitForChild("BottomRightFin")

for i, v in pairs({LeftShoulder, RightShoulder, LeftHip, RightHip}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

function Move(Time)
	local LimbAmplitude = 0.1
	local LimbFrequency = 3.5
	local LimbDesiredAngle1 = (LimbAmplitude * math.sin(Time * LimbFrequency))
	local LimbDesiredAngle2 = -(LimbAmplitude * math.sin(Time * LimbFrequency))
	
	LeftShoulder.DesiredAngle = LimbDesiredAngle1
	RightShoulder.DesiredAngle = LimbDesiredAngle2
	LeftHip.DesiredAngle = LimbDesiredAngle2
	RightHip.DesiredAngle = LimbDesiredAngle1
	
end

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	Move(Time)
end)