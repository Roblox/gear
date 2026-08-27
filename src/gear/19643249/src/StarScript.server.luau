arrow = script.Parent
damage = 30

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=11113679"
HitSound.Parent = arrow
HitSound.Volume = .5


function stick(hit)
	-- joint myself to the thing i hit

	local weld = Instance.new("Weld")

	weld.Part0 = arrow
	weld.Part1 = hit

	-- correction term to account for average skew between physics update and heartbeat
	local HitPos = arrow.Position --+ (-arrow.Velocity * (1/60)) --+ (arrow.CFrame.lookVector * .5)

	local CJ = CFrame.new(HitPos)
	local C0 = arrow.CFrame:inverse() *CJ
	local C1 = hit.CFrame:inverse() * CJ
	
	weld.C0 = C0
	weld.C1 = C1

	weld.Parent = arrow

end


function onTouched(hit)

	connection:disconnect()

	stick(hit)
	HitSound:Play()

	humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid~=nil then
		tagHumanoid(humanoid)

			humanoid:TakeDamage(damage)

		wait(1)
		untagHumanoid(humanoid)
	end
	
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = arrow:findFirstChild("creator")
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

connection = arrow.Touched:connect(onTouched)

wait(10)

arrow.Parent = nil