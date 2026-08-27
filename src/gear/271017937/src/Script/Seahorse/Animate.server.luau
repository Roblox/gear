--Made by Luckymaxer

Figure = script.Parent

RunService = game:GetService("RunService")

Body = Figure:WaitForChild("Body")
LeftMotor = Body:WaitForChild("LeftMotor")
RightMotor = Body:WaitForChild("RightMotor")
ParticlePart = Figure:WaitForChild("ParticlePart")

for i, v in pairs({LeftMotor, RightMotor}) do
	if v and v.Parent then
		v.DesiredAngle = 0
		v.CurrentAngle = 0
	end
end

function Move(Time)
	local LimbAmplitude = 0.1
	local LimbFrequency = 6
	local LimbDesiredAngle = (LimbAmplitude * math.sin(Time * LimbFrequency))
	
	LeftMotor.DesiredAngle = LimbDesiredAngle
	RightMotor.DesiredAngle = -LimbDesiredAngle
	
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