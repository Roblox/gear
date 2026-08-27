--Made by Luckymaxer

arrow = script.Parent
creator = arrow:WaitForChild("creator")

debris = game:GetService("Debris")

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=28913460"
HitSound.Parent = arrow
HitSound.Volume = 1


function onTouched(hit)

	arrow.RaySound.Looped = false
	arrow.RaySound:Stop()
	if hit.Parent ~= nil and hit.Parent ~= creator.Value.Character then
		if hit.Parent:IsA("Hat") then return end
		HitSound:Play()
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil then
			if not hit.Parent:FindFirstChild("OutfitScript") then
				local transmorpher = arrow.OutfitScript:clone()
				transmorpher.Parent = humanoid.Parent
				transmorpher.Disabled = false
			end
		else
			local e = Instance.new("Explosion")
			e.BlastPressure = 0
			e.BlastRadius = 2
			e.Position = arrow.Position
			e.Parent = game.Workspace
		end
		arrow:Destroy()
	end
	
end

connection = arrow.Touched:connect(onTouched)