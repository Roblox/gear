--Made by Luckymaxer

Particle = script.Parent

Visible = script:WaitForChild("Visible")

wait(Visible.Value)

pcall(function()
	Particle.Enabled = false
end)