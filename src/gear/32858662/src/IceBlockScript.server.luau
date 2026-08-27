local humanoid = script.Parent:FindFirstChild("Humanoid")
if humanoid == nil then return end
local health = humanoid.Health

while true do
	if humanoid.Health < health then
		humanoid:TakeDamage(-10)
		if humanoid.Health > health then
			humanoid.Health = health
		end
	end
	wait()
end
