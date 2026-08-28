local Particle = script:WaitForChild("Particle")

local Character = script.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local AffectedParts = {"head"} -- Highlight the bodyparts with the name found

if Humanoid and Humanoid.Health ~= 0 then
	
	if Humanoid.Health > 1 then
		Humanoid.Health = 1
	end
	
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
				game:GetService("Debris"):AddItem(effect,3)
				effect.Parent = bodyparts
				effect.Enabled = true
			end
		end
	end
end

script:Destroy()