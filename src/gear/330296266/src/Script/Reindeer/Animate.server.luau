--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")

Body = Figure:WaitForChild("Body")
LeftShoulder = Body:WaitForChild("Left Shoulder")
RightShoulder = Body:WaitForChild("Right Shoulder")
LeftHip = Body:WaitForChild("Left Hip")
RightHip = Body:WaitForChild("Right Hip")

Bells = Body:FindFirstChild("Bells")
PlaySound = {Last = 0, Duration = {Delay = 0, Min = 1.05, Max = 1.05}}

for i, v in pairs({LeftShoulder, RightShoulder, LeftHip, RightHip}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

function Move(Time)
	local LimbAmplitude = 0.2
	local LimbFrequency = 5
	local TailAngle = (0.2 * math.sin(Time * 2))
	local LimbDesiredAngle1 = (LimbAmplitude * math.sin(Time * LimbFrequency))
	local LimbDesiredAngle2 = (LimbAmplitude * math.sin(Time * LimbFrequency))
	
	LeftShoulder.DesiredAngle = LimbDesiredAngle1
	RightShoulder.DesiredAngle = -LimbDesiredAngle2
	LeftHip.DesiredAngle = LimbDesiredAngle2
	RightHip.DesiredAngle = -LimbDesiredAngle1
	
end

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	if Bells then
		local Now = tick()
		if (Now - PlaySound.Last) >= PlaySound.Duration.Delay then
			PlaySound.Last = Now
			PlaySound.Duration.Delay = (math.random((PlaySound.Duration.Min * 100), (PlaySound.Duration.Max * 100)) * 0.01)
			Bells:Play()
		end
	end
	Move(Time)
end)