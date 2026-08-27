--Made by Luckymaxer

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Character = script.Parent

Humanoid = Character:FindFirstChild("Humanoid")

Fire = script:FindFirstChild("Fire")

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Fire or not Humanoid or Humanoid.Health > 0 then
	return
end

PartsEffected = {}

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") and v.Transparency < 1 then
		for ii, vv in pairs(v:GetChildren()) do
			if vv:IsA("Fire") then
				vv:Destroy()
			end
		end
		local FireEffect = Fire:Clone()
		FireEffect.Enabled = true
		FireEffect.Parent = v
		table.insert(PartsEffected, {Part = v, Fire = FireEffect})
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
					v.Fire.Enabled = false
					Debris:AddItem(v.Part, 1.5)
				end
			else
				table.remove(PartsEffected, i)
			end
		end
	end
end)