--Made by Luckymaxer

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")

Regenerating = false

function RegenerateHealth()
	if Regenerating then
		return
	end
	Regenerating = true
	while Humanoid.Health < Humanoid.MaxHealth do
		local Second = wait(1)
		local Health = Humanoid.Health
		if Health > 0 and Health < Humanoid.MaxHealth then
			local NewHealthDelta = (0.01 * Second * Humanoid.MaxHealth)
			Health = (Health + NewHealthDelta)
			Humanoid.Health = math.min(Health, Humanoid.MaxHealth)
		end
	end
	if Humanoid.Health > Humanoid.MaxHealth then
		Humanoid.Health = Humanoid.MaxHealth
	end
	Regenerating = false
end

Humanoid.HealthChanged:connect(RegenerateHealth)