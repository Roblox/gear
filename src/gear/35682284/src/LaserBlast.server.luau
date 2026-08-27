ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1



function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		if tostring(ball.creator.Value) ~= humanoid.Parent.Name then
--		tagHumanoid(humanoid)
--		humanoid:TakeDamage(damage)
--		untagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
			ball.Parent = nil
		end
	end

	if hit:findFirstChild("EnergyOrb") ~= nil then
		if tostring(hit.creator.Value) ~= tostring(ball.creator.Value) then
			ball.Parent = nil
		end
	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
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
local orbitingVelocity = 15
local radius = 5
local radiusSq = radius*radius
local ovSq = orbitingVelocity*orbitingVelocity
for i = 1, 500 do
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		myMaker = Workspace:findFirstChild(tostring(tag.Value))
		if myMaker ~= nil then
			radius_tag = myMaker:findFirstChild("Radius")
			if radius_tag ~= nil then
				radius = radius_tag.Value
				radiusSq = radius*radius
			end

			MPos = myMaker.PrimaryPart.Position
			dPos = ball.Position - MPos
			
			ball.BodyForce.force = ball:getMass()*Vector3.new(-ovSq*dPos.X/radiusSq, -ovSq*dPos.Y/radiusSq + 196.1643, -ovSq*dPos.Z/radiusSq)
			
			-- find unit vector towards us
			unitVectorTowardsUs = dPos.unit

			-- take away component towards us (entirely if radius is 5, otherwise, less)
			newVelocity = ball.Velocity - (1/(1 + math.abs(dPos.magnitude - radius)))*unitVectorTowardsUs*ball.Velocity:Dot(unitVectorTowardsUs)
				
			-- and ensure speed stays at orbiting velocity
			ball.Velocity = newVelocity.unit * orbitingVelocity
		end
	end
	wait(.01)
end
--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()
ball.Parent = nil