ball = script.Parent
damage = 15

debris = game:GetService("Debris")
debris:AddItem(ball, 10)

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Pitch = .5
HitSound.Parent = ball




function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	connection:disconnect()
	local bf = ball:FindFirstChild("BulletFloat")
	if (bf ~= nil) then bf:Remove() end

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
	end

	HitSound:Play()


end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 1)
	end
end



connection = ball.Touched:connect(onTouched)


