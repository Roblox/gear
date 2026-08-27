local Part = script.Parent

local BrickRandom = Random.new()

while true do
	wait(0.5)
	Part.Color = Color3.new(BrickRandom:NextNumber(), BrickRandom:NextNumber(), BrickRandom:NextNumber())
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Color = ColorSequence.new(Part.Color, Part.Color)
		end
	end
end