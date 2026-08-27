arrow = script.Parent

debris = game:GetService("Debris")

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=28913460"
HitSound.Parent = arrow
HitSound.Volume = 1


function onTouched(hit)

	arrow.RaySound.Looped = false
	arrow.RaySound:Stop()
	if hit.Parent then
		HitSound:Play()
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local transmorpher = arrow.TransmorphScript:Clone()
			transmorpher.Parent = humanoid.Parent
			transmorpher.Disabled = false
		else
			local e = Instance.new("Explosion")
			e.BlastPressure = 0
			e.BlastRadius = 2
			e.Position = arrow.Position
			e.Parent = workspace
		end
		arrow:Destroy()
	end
	
end



connection = arrow.Touched:Connect(onTouched)

debris:AddItem(arrow,30)