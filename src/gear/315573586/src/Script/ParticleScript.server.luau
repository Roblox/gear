--Made by Luckymaxer

Part = script.Parent

Duration = Part:WaitForChild("Duration")

wait(Duration.Value)

if Part:IsA("Part") then
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
elseif Part:IsA("ParticleEmitter") then
	Part.Enabled = false
end