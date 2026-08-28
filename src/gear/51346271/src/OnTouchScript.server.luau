local dart = script.Parent

creatorTag = dart:FindFirstChild("creator")

HitSound = Instance.new("Sound") 
HitSound.Name = "HitSound" 
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266" 
HitSound.Parent = ball 
HitSound.Volume = 1 


function onTouch(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid then 
		dart:Remove()
		HitSound:Play() 
		creatorTag.Parent = humanoid
		humanoid:TakeDamage(30)
		wait(1.0)
		creatorTag:Remove()
		wait(0.5)
		script:Remove()
	end
end

dart.Touched:connect(onTouch)
