--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")

Body = Figure:WaitForChild("Body")
LeftWing = Body:WaitForChild("Left Wing")
RightWing = Body:WaitForChild("Right Wing")

for i, v in pairs({LeftWing, RightWing}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

function Move(Time)
	local LimbAmplitude = 0.2
	local LimbFrequency = 5
	local LimbDesiredAngle = (LimbAmplitude * math.sin(Time * LimbFrequency))
	
	LeftWing.DesiredAngle = LimbDesiredAngle
	RightWing.DesiredAngle = -LimbDesiredAngle
	
end

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	Move(Time)
end)