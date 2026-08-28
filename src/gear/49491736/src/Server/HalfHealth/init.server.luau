local Particle = script:WaitForChild("Particle")

local Character = script.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local AffectedParts = {"torso"} -- Highlight the bodyparts with the name found

local ParticleTable = {}

if Humanoid and Humanoid.Health ~= 0 then
	Humanoid.Health = Humanoid.Health * 0.5 
	Humanoid.MaxHealth = 50.0

	for _,bodyparts in pairs(Character:GetChildren()) do
		if bodyparts:IsA("BasePart") then
			local found = false
			for _,v in pairs(AffectedParts) do
				if string.find(string.lower(bodyparts.Name),v) then
					found = true
				end
			end
			if found then
				local effect = Particle:Clone()
				ParticleTable[#ParticleTable+1] = effect
				effect.Parent = bodyparts
				effect.Enabled = true
			end
		end
	end
		wait(10.0)
		Humanoid.MaxHealth = 100.0
		if Humanoid.Health * 2.0 <= Humanoid.MaxHealth then Humanoid.Health = Humanoid.Health * 2.0
		else Humanoid.Health = 100 end
end

for _,particles in pairs(ParticleTable) do
	if particles then
		particles:Destroy()
	end
end
script:Destroy()