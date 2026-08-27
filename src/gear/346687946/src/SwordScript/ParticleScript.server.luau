--Made by Luckymaxer

Particle = script.Parent

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Duration = Particle:FindFirstChild("Duration")

function DisableParticles()
	Particle.Enabled = false
	Debris:AddItem(Particle, 0.5)
end

if not Duration or Duration.Value <= 0 then
	DisableParticles()
else
	RunService.Stepped:connect(function(Time, Step)
		Duration.Value = (Duration.Value - Step)
		if Duration.Value <= 0 then
			DisableParticles()
		end
	end)
end