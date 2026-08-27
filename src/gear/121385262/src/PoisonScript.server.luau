local Character = script.Parent
local Torso = Character:WaitForChild('Torso')
local Humanoid = Character:WaitForChild('Humanoid')
local StartedAt = tick()
local LastDamage = 0

local EffectParts = {}

Spawn(function()
	while true do
		if (tick()-StartedAt) > 10 then
			break
		end
		if (tick()-LastDamage) > 1 then
			Humanoid:TakeDamage(10)
			LastDamage = tick()
		end
		for eff, _ in pairs(EffectParts) do
			eff.Offs = eff.Offs + 0.03
			if eff.Offs > 1 then
				EffectParts[eff] = nil
				eff.Part:Destroy()
			else
				eff.Part.Transparency = eff.Offs
				eff.Part.CFrame = CFrame.new(Torso.Position)*CFrame.new(eff.X, eff.Y + 5 * eff.Offs, eff.Z)
			end
		end
		if math.random(1,7) == 1 then
			local eff = {}
			eff.Part = Instance.new('Part', Character)
			eff.Part.Name = 'Effect'
			eff.Part.CanCollide = false
			eff.Part.Anchored = true
			eff.Part.FormFactor = 'Custom'
			eff.Part.Size = Vector3.new(0,math.random(10,30)/10,0)
			eff.Part.BrickColor = BrickColor.new(1020)
			eff.Y = math.random(-10,20)/10
			eff.X = math.random(-20,20)/10
			eff.Offs = 0
			eff.Z = math.random(-20,20)/10
			EffectParts[eff] = true
		end
		wait()
	end
	for eff, _ in pairs(EffectParts) do
		eff.Part:Destroy()
	end
	script:Destroy()
end)