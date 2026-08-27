ball = script.Parent
damage = 80
maxSpeed = 230


function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		local theHurt = damage * math.abs(ball.Velocity.magnitude/maxSpeed)
		print(theHurt)
		humanoid:TakeDamage(theHurt)
		untagHumanoid(humanoid)
		if theHurt > 30 then
			if hit.Name ~= "Head" and hit.Name ~= "Torso" then
				print(hit)
				hit:BreakJoints()
			end
		end
		ball.Parent = nil
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
