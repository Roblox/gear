local Particle = script:WaitForChild("Particle")

local Creator = script:WaitForChild("Creator")

local Character = script.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local AffectedParts = {"torso","leg","foot"} -- Highlight the bodyparts with the name found

local ParticleTable = {}


function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

if Humanoid and Humanoid.Health ~= 0 then
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid,Creator)
	Humanoid:TakeDamage(50)
	Humanoid.WalkSpeed = 12.0
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
	Humanoid.WalkSpeed = 16.0
end
for _,particles in pairs(ParticleTable) do
	if particles then
		particles:Destroy()
	end
end
script:Destroy()