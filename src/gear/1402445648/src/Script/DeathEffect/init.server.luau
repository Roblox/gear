--Made by Luckymaxer

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Character = script.Parent

Humanoid = Character:FindFirstChild("Humanoid")

Smoke = script:FindFirstChild("Smoke")

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Smoke or not Humanoid or Humanoid.Health > 0 then
	return
end

PartsEffected = {}

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") and v.Transparency < 1 then
		v.Velocity = (v.Velocity + (CFrame.Angles((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01)).lookVector * math.random(1, 5)))
		v.RotVelocity = Vector3.new((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01))
		for ii, vv in pairs(v:GetChildren()) do
			if vv:IsA("ParticleEmitter") then
				vv:Destroy()
			end
		end
		local SmokeEffect = Smoke:Clone()
		SmokeEffect.Enabled = true
		SmokeEffect.Parent = v
		table.insert(PartsEffected, {Part = v, Smoke = SmokeEffect})
	end
end

FadeLoop = RunService.Stepped:connect(function(Time, Step)
	if #PartsEffected == 0 then
		if FadeLoop then
			FadeLoop:disconnect()
			return
		end
	else
		for i, v in pairs(PartsEffected) do
			if v.Part.Transparency < 1 then
				v.Part.Transparency = (v.Part.Transparency + 0.01)
				if v.Part.Transparency >= 1 then
					v.Smoke.Enabled = false
					Debris:AddItem(v.Part, 4)
				end
			else
				table.remove(PartsEffected, i)
			end
		end
	end
end)