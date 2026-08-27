--Made by Luckymaxer

Particle = script.Parent

Debris = game:GetService("Debris")

Duration = Particle:WaitForChild("Duration")

while Duration.Value > 0 do
	local Time = wait()
	Duration.Value = (Duration.Value - Time)
end

Particle.Enabled = false

Debris:AddItem(Particle, 2)