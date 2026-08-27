--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")

Body = Figure:WaitForChild("Body")
Tail = Body:WaitForChild("Tail")
LeftShoulder = Body:WaitForChild("Left Shoulder")
RightShoulder = Body:WaitForChild("Right Shoulder")
LeftHip = Body:WaitForChild("Left Hip")
RightHip = Body:WaitForChild("Right Hip")
ParticlePart = Figure:WaitForChild("ParticlePart")

for i, v in pairs({Tail, LeftShoulder, RightShoulder, LeftHip, RightHip}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

function Move(Time)
	local LimbAmplitude = 0.15
	local LimbFrequency = 5
	local TailAngle = (0.2 * math.sin(Time * 2))
	local LimbDesiredAngle1 = (LimbAmplitude * math.sin(Time * LimbFrequency))
	local LimbDesiredAngle2 = -(LimbAmplitude * math.sin(Time * LimbFrequency))
	
	Tail.DesiredAngle = TailAngle
	LeftShoulder.DesiredAngle = LimbDesiredAngle1
	RightShoulder.DesiredAngle = -LimbDesiredAngle2
	LeftHip.DesiredAngle = LimbDesiredAngle2
	RightHip.DesiredAngle = -LimbDesiredAngle1
	
end

function DisplayParticles()
	local Moving = ((Body.Velocity * Vector3.new(1, 0, 1)).Magnitude > 10)
	for i, v in pairs(ParticlePart:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = Moving
		end
	end
end

RunService.Stepped:connect(function()
	local _, Time = wait(0.1)
	Move(Time)
	DisplayParticles()
end)