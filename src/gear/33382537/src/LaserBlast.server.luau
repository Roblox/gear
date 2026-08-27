ball = script.Parent
damage = 6

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=33286094"
HitSound.Parent = ball
HitSound.Volume = 1


function onTouched(hit)

	HitSound:Play()

	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
		untagHumanoid(humanoid)
		ball:Destroy()
	elseif ball.Velocity.magnitude * ball:GetMass() > hit:GetMass() and hit.Anchored == false then
		hit:BreakJoints()
		local ratio = ball:GetMass()/hit:GetMass()
		local addVelo = ball.Velocity * ratio
		hit.Velocity = Vector3.new(hit.Velocity.x + addVelo.x,hit.Velocity.y + addVelo.y,hit.Velocity.z + addVelo.z)
		ball:Destroy()
	end


end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
	end
end


function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

connection = ball.Touched:connect(onTouched)

wait(5)

ball.Parent = nil